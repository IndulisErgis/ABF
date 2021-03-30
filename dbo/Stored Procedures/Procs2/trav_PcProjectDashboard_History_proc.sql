
CREATE PROCEDURE dbo.trav_PcProjectDashboard_History_proc 
@ProjectId int,
@PhaseId nvarchar(10),
@ProjectDetailId int,
@PhaseYn bit = 0,
@FiscalYear smallint,
@FiscalPeriod smallint
AS
BEGIN TRY
DECLARE @typeCounter tinyint
SET NOCOUNT ON

CREATE TABLE #tmpProjectDetailType 
(
	[ProjectDetailId] int NOT NULL,
	[Type] tinyint NOT NULL,
	[TrackIncomeYn] bit NOT NULL
	CONSTRAINT [PK_#tmpProjectDetailType] PRIMARY KEY CLUSTERED ([ProjectDetailId],[Type]) ON [PRIMARY] 
)

SET @typeCounter = 0

WHILE @typeCounter < 4
BEGIN
	IF (@ProjectDetailId IS NOT NULL) --task level
	BEGIN
		INSERT INTO #tmpProjectDetailType([ProjectDetailId], [Type], [TrackIncomeYn])
		SELECT Id, @typeCounter, CASE WHEN Billable = 0 OR FixedFee = 1 THEN 0 ELSE 1 END 
		FROM dbo.tblPcProjectDetail
		WHERE Id = @ProjectDetailId
	END
	ELSE IF @PhaseYn = 1 --phase level
	BEGIN
		INSERT INTO #tmpProjectDetailType([ProjectDetailId], [Type], [TrackIncomeYn])
		SELECT Id, @typeCounter, CASE WHEN Billable = 0 OR FixedFee = 1 THEN 0 ELSE 1 END
		FROM dbo.tblPcProjectDetail
		WHERE ProjectId = @ProjectId AND ((@PhaseId IS NULL AND PhaseId IS NULL AND TaskId IS NOT NULL) OR 
			(@PhaseId IS NOT NULL AND PhaseId = @PhaseId))		
	END
	ELSE --project level
	BEGIN
		INSERT INTO #tmpProjectDetailType([ProjectDetailId], [Type], [TrackIncomeYn])
		SELECT Id, @typeCounter, CASE WHEN Billable = 0 OR FixedFee = 1 THEN 0 ELSE 1 END
		FROM dbo.tblPcProjectDetail
		WHERE ProjectId = @ProjectId	
	END
	
	SET @typeCounter = @typeCounter + 1
END

-- For Billvia SD (when source =13) TrackIncomeYn checking not needed.  
SELECT t.[Type] AS Category
	, SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 )THEN CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END ELSE 0 END) AS Income
	, SUM(CASE WHEN a.[Status] IN (2,4) THEN ExtCost ELSE 0 END) AS Cost 
	, SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END ELSE 0 END) 
		- SUM(CASE WHEN a.[Status] IN (2,4) THEN ExtCost ELSE 0 END) Profit
	, CASE WHEN SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END ELSE 0 END) = 0 THEN 0 
		ELSE	
		(SUM(CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END) 
		- SUM(CASE WHEN a.[Status] IN (2,4) THEN ExtCost ELSE 0 END))
		/SUM(CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END)*100 END AS ProfitPct
FROM #tmpProjectDetailType t 
LEFT JOIN 
(	SELECT ProjectDetailId, [Type], [Status], ExtCost, ExtIncome, ExtIncomeBilled, FiscalYear, FiscalPeriod ,[Source]
	FROM dbo.tblPcActivity 
	WHERE [type] BETWEEN 0 AND 3 AND [Status] BETWEEN 2 AND 5 AND [Source] <> 11
) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[type] = a.[type]
WHERE (a.FiscalYear = @FiscalYear OR a.FiscalYear IS NULL) AND (a.FiscalPeriod = @FiscalPeriod OR a.FiscalPeriod IS NULL) 
GROUP BY t.[Type]

UNION ALL

SELECT t.[Type] + 4
	, SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END ELSE 0 END) AS Income
	, SUM(CASE WHEN a.[Status] IN (2,4) THEN ExtCost ELSE 0 END) AS Cost
	,  SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END ELSE 0 END) 
		- SUM(CASE WHEN a.[Status] IN (2,4) THEN ExtCost ELSE 0 END) Profit
	, CASE WHEN SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END ELSE 0 END) = 0 THEN 0 
		ELSE	
		(SUM(CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END) 
		- SUM(CASE WHEN a.[Status] IN (2,4) THEN ExtCost ELSE 0 END))/SUM(CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END)*100 END AS ProfitPct
FROM #tmpProjectDetailType t 
LEFT JOIN 
(	SELECT ProjectDetailId, [Type], [Status], ExtCost, ExtIncome, ExtIncomeBilled, FiscalYear, FiscalPeriod ,[Source]
	FROM dbo.tblPcActivity 
	WHERE [type] BETWEEN 0 AND 3 AND [Status] BETWEEN 2 AND 5 AND [Source] <> 11
) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[type] = a.[type]
WHERE a.FiscalYear = @FiscalYear OR a.FiscalYear IS NULL
GROUP BY t.[Type]

UNION ALL

SELECT t.[Type] + 8
	, SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END ELSE 0 END) AS Income
	, SUM(CASE WHEN a.[Status] IN (2,4) THEN ExtCost ELSE 0 END) AS Cost
	,  SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END ELSE 0 END) 
		- SUM(CASE WHEN a.[Status] IN (2,4) THEN ExtCost ELSE 0 END) Profit
	, CASE WHEN SUM(CASE WHEN (t.TrackIncomeYn=1  OR a.[Source] =13 ) THEN CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END ELSE 0 END) = 0 THEN 0 
		ELSE	
		(SUM(CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END) 
		- SUM(CASE WHEN a.[Status] IN (2,4) THEN ExtCost ELSE 0 END))/SUM(CASE WHEN a.[Status] = 4 THEN a.ExtIncomeBilled WHEN a.[Status] IN (2,3,5) THEN a.ExtIncome ELSE 0 END)*100 END AS ProfitPct
FROM #tmpProjectDetailType t 
LEFT JOIN 
(	SELECT ProjectDetailId, [Type], [Status], ExtCost, ExtIncome, ExtIncomeBilled, FiscalYear, FiscalPeriod ,[Source]
	FROM dbo.tblPcActivity 
	WHERE [type] BETWEEN 0 AND 3 AND [Status] BETWEEN 2 AND 5 AND [Source] <> 11
) a ON t.ProjectDetailId = a.ProjectDetailId AND t.[type] = a.[type]
GROUP BY t.[Type]

SELECT ISNULL(SUM(BilledAmount),0) AS PTDAmount, ISNULL(SUM(WriteUD),0) AS PTDWriteUD,
	ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear THEN BilledAmount ELSE 0 END),0) AS YTDAmount, 
	ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND FiscalPeriod = @FiscalPeriod THEN BilledAmount ELSE 0 END),0) AS PdTDAmount, 
	ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear THEN WriteUD ELSE 0 END),0) AS YTDWriteUD, 
	ISNULL(SUM(CASE WHEN FiscalYear = @FiscalYear AND FiscalPeriod = @FiscalPeriod THEN WriteUD ELSE 0 END),0) AS PdTDWriteUD,
	ISNULL(SUM(DepositAmount),0) AS DepositAmount, ISNULL(SUM(DepositAppliedAmount),0) AS DepositAppliedAmount, 
	MAX(LastDateBilled) AS LastDateBilled
FROM
(
SELECT a.ProjectDetailId, ISNULL(l.FiscalYear,a.FiscalYear) AS FiscalYear, ISNULL(l.GLPeriod,a.FiscalPeriod) AS FiscalPeriod, 
	CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtIncomeBilled WHEN a.[Type] = 6 THEN a.ExtIncome WHEN a.[Type] = 7 THEN -a.ExtIncome ELSE 0 END AS BilledAmount, 
	CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtIncomeBilled - a.ExtIncome ELSE 0 END AS WriteUD,
	CASE WHEN a.[Type] = 4 THEN a.ExtIncome ELSE 0 END DepositAmount,
	CASE WHEN a.[Type] = 5 THEN a.ExtIncome ELSE 0 END DepositAppliedAmount, d.LastDateBilled
FROM (SELECT ProjectDetailId FROM #tmpProjectDetailType GROUP BY ProjectDetailId) t INNER JOIN  dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
	INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
	LEFT JOIN dbo.tblArHistDetail h ON a.Id = h.TransHistId 
	LEFT JOIN dbo.tblArHistHeader l ON h.PostRun = l.PostRun AND h.TransID = l.TransId
WHERE ((d.FixedFee = 0 AND a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 4) OR --Non fixed fee billing
	(d.FixedFee = 1 AND a.[Type] = 6 AND a.[Status] IN (2,5)) OR --Posted and completed Fixed fee billing
	(a.[Type] IN (4,5,7) AND a.[Status] = 2))  AND ISNULL(l.VoidYn,0) = 0 --Deposit, Deposit applied, Credit memo
) AS BillingDetail 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectDashboard_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcProjectDashboard_History_proc';

