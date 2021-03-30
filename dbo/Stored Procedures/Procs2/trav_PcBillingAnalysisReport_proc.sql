
CREATE PROCEDURE dbo.trav_PcBillingAnalysisReport_proc 
@FiscalYear smallint,
@FiscalPeriod smallint,
@IncludeTask bit,
@ZeroDepositBalanceOnly bit

AS
BEGIN TRY
SET NOCOUNT ON

CREATE TABLE #tmpProjectDetail 
(
	[ProjectDetailId] int NOT NULL,
	[BilledPTD] Decimal(28,3) NOT NULL DEFAULT(0),
	[BilledYTD] Decimal(28,3) NOT NULL DEFAULT(0),
	[BilledPRTD] Decimal(28,3) NOT NULL DEFAULT(0),
	[WritePTD] Decimal(28,3) NOT NULL DEFAULT(0),
	[WriteYTD] Decimal(28,3) NOT NULL DEFAULT(0),
	[WritePRTD] Decimal(28,3) NOT NULL DEFAULT(0),
	[DepositAdvances] Decimal(28,3) NOT NULL DEFAULT(0),
	[DepositApplied] Decimal(28,3) NOT NULL DEFAULT(0)
	CONSTRAINT [PK_#tmpProjectDetail] PRIMARY KEY CLUSTERED ([ProjectDetailId]) ON [PRIMARY] 
)

INSERT INTO #tmpProjectDetail(ProjectDetailId)
SELECT d.Id
FROM dbo.tblPcProject p INNER JOIN dbo.tblPcProjectDetail d ON p.Id = d.ProjectId
WHERE p.CustId IS NOT NULL AND d.Billable = 1 AND d.Speculative = 0--Customer ID is not null, billable, non-speculative project/task
	AND p.Id IN (SELECT ProjectId FROM #tmpProjectList)

--Project to Date billed
UPDATE #tmpProjectDetail SET BilledPrTD = e.PrTDAmount, BilledPTD = e.PTDAmount, BilledYTD = e.YTDAmount,
	WritePTD = e.PTDWriteUD, WritePRTD = e.PrTDWriteUD, WriteYTD = e.YTDWriteUD,
	DepositAdvances = e.DepositAmount, DepositApplied = e.DepositAppliedAmount
FROM #tmpProjectDetail INNER JOIN (
		SELECT ProjectDetailId
			, SUM(CASE WHEN (FiscalYear < @FiscalYear) OR (FiscalYear = @FiscalYear AND FiscalPeriod <= @FiscalPeriod) THEN BilledAmount ELSE 0 END) AS PrTDAmount
			, SUM(CASE WHEN (FiscalYear < @FiscalYear) OR (FiscalYear = @FiscalYear AND FiscalPeriod <= @FiscalPeriod) THEN WriteUD ELSE 0 END) AS PrTDWriteUD
			, SUM(CASE WHEN FiscalYear = @FiscalYear AND FiscalPeriod <= @FiscalPeriod THEN BilledAmount ELSE 0 END) AS YTDAmount
			, SUM(CASE WHEN FiscalYear = @FiscalYear AND FiscalPeriod = @FiscalPeriod THEN BilledAmount ELSE 0 END) AS PTDAmount
			, SUM(CASE WHEN FiscalYear = @FiscalYear AND FiscalPeriod <= @FiscalPeriod THEN WriteUD ELSE 0 END) AS YTDWriteUD
			, SUM(CASE WHEN FiscalYear = @FiscalYear AND FiscalPeriod = @FiscalPeriod THEN WriteUD ELSE 0 END) AS PTDWriteUD
			, SUM(CASE WHEN (FiscalYear < @FiscalYear) OR (FiscalYear = @FiscalYear AND FiscalPeriod <= @FiscalPeriod) THEN DepositAmount ELSE 0 END) AS DepositAmount
			, SUM(CASE WHEN (FiscalYear < @FiscalYear) OR (FiscalYear = @FiscalYear AND FiscalPeriod <= @FiscalPeriod) THEN DepositAppliedAmount ELSE 0 END) AS DepositAppliedAmount
			, SUM(CASE WHEN (FiscalYear < @FiscalYear) OR (FiscalYear = @FiscalYear AND FiscalPeriod <= @FiscalPeriod) THEN DepositAmount ELSE 0 END) 
				- SUM(CASE WHEN (FiscalYear < @FiscalYear) OR (FiscalYear = @FiscalYear AND FiscalPeriod <= @FiscalPeriod) THEN DepositAppliedAmount ELSE 0 END) AS DepositBalance 
		FROM
		(
		SELECT a.ProjectDetailId, ISNULL(l.FiscalYear,a.FiscalYear) AS FiscalYear, ISNULL(l.GLPeriod,a.FiscalPeriod) AS FiscalPeriod, 
			CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtIncomeBilled WHEN a.[Type] = 6 THEN a.ExtIncome WHEN a.[Type] = 7 THEN -a.ExtIncome ELSE 0 END AS BilledAmount, 
			CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtIncomeBilled - a.ExtIncome ELSE 0 END AS WriteUD,
			CASE WHEN a.[Type] = 4 THEN a.ExtIncome ELSE 0 END DepositAmount,
			CASE WHEN a.[Type] = 5 THEN a.ExtIncome ELSE 0 END DepositAppliedAmount
		FROM #tmpProjectDetail t INNER JOIN  dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
			INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
			LEFT JOIN dbo.tblArHistDetail h ON a.Id = h.TransHistId 
			LEFT JOIN dbo.tblArHistHeader l ON h.PostRun = l.PostRun AND h.TransID = l.TransId
		WHERE ((d.FixedFee = 0 AND a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 4) OR --Non fixed fee billing
			(d.FixedFee = 1 AND a.[Type] = 6 AND a.[Status] IN (2,5)) OR --Posted and completed Fixed fee billing
			(a.[Type] IN (4,5,7) AND a.[Status] = 2))  AND ISNULL(l.VoidYn,0) = 0 --Deposit, Deposit applied, Credit memo
		) AS BillingDetail 
		GROUP BY ProjectDetailId
		) AS e ON #tmpProjectDetail.ProjectDetailId = e.ProjectDetailId
	
IF @IncludeTask = 1
BEGIN
	SELECT p.CustId, p.ProjectName AS ProjectId, d.PhaseId, d.TaskId, d.[Description], d.LastDateBilled, t.BilledPTD, t.BilledYTD, 
		t.BilledPRTD, t.WritePTD, t.WriteYTD, t.WritePRTD, t.DepositAdvances, t.DepositApplied, t.DepositAdvances - t.DepositApplied AS DepositBalance
	FROM #tmpProjectDetail t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	WHERE @ZeroDepositBalanceOnly = 0 OR t.DepositAdvances <> t.DepositApplied
END
ELSE
BEGIN
	SELECT p.CustId, p.ProjectName AS ProjectId, NULL AS PhaseId, NULL AS TaskId, p.[Description], MAX(d.LastDateBilled) AS LastDateBilled,
		SUM(t.BilledPRTD) AS BilledPRTD,SUM(t.BilledPTD) AS BilledPTD,SUM(t.BilledYTD) AS BilledYTD, 
		SUM(t.WritePTD) AS WritePTD, SUM(t.WriteYTD) AS WriteYTD, SUM(t.WritePRTD) AS WritePRTD, 
		SUM(t.DepositAdvances) AS DepositAdvances, SUM(t.DepositApplied) AS DepositApplied, SUM(t.DepositAdvances) - SUM(t.DepositApplied) AS DepositBalance
	FROM #tmpProjectDetail t INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
		INNER JOIN dbo.trav_PcProject_view p ON d.ProjectId = p.Id 
	GROUP BY p.CustId, p.ProjectName, p.[Description] 
	HAVING @ZeroDepositBalanceOnly = 0 OR SUM(t.DepositAdvances) <> SUM(t.DepositApplied)
END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingAnalysisReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingAnalysisReport_proc';

