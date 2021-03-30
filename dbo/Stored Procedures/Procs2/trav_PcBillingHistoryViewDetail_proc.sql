
CREATE PROCEDURE dbo.trav_PcBillingHistoryViewDetail_proc 
@ProjectDetailId int
AS
BEGIN TRY
SET NOCOUNT ON

	SELECT a.Id, a.[Type], l.InvcDate, l.InvcNum, ISNULL(l.FiscalYear,a.FiscalYear) AS FiscalYear, ISNULL(l.GLPeriod,a.FiscalPeriod) AS FiscalPeriod, 
		CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtIncomeBilled WHEN a.[Type] = 6 THEN a.ExtIncome WHEN a.[Type] = 7 THEN -a.ExtIncome ELSE 0 END AS BilledAmount, 
		CASE WHEN a.[Type] BETWEEN 0 AND 3 THEN a.ExtIncomeBilled - a.ExtIncome ELSE 0 END AS WriteUD
	FROM dbo.tblPcActivity a INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
		LEFT JOIN dbo.tblArHistDetail h ON a.Id = h.TransHistId 
		LEFT JOIN dbo.tblArHistHeader l ON h.PostRun = l.PostRun AND h.TransID = l.TransId
	WHERE a.ProjectDetailid = @ProjectDetailId AND 
		((d.FixedFee = 0 AND a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 4) OR --Non fixed fee billing
		(d.FixedFee = 1 AND a.[Type] = 6 AND (a.[Status] = 2 OR a.[Status] = 5)) OR --Fixed fee billing
		(a.[Type] = 7 AND a.[Status] = 2)) --Credit memo
		AND ISNULL(l.VoidYn,0) = 0
	
	SELECT a.Id, a.[Type], a.ActivityDate, a.FiscalYear, a.FiscalPeriod, CASE WHEN a.[Type] = 4 THEN a.ExtIncome ELSE -a.ExtIncome END DepositAmount
	FROM dbo.tblPcActivity a INNER JOIN dbo.tblPcProjectDetail d ON a.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id
		LEFT JOIN dbo.tblArHistDetail h ON a.Id = h.TransHistId 
		LEFT JOIN dbo.tblArHistHeader l ON h.PostRun = l.PostRun AND h.TransID = l.TransId
	WHERE a.ProjectDetailid = @ProjectDetailId AND a.[Type] IN (4,5) AND a.[Status] = 2 --Deposit, Deposit applied
		AND ISNULL(l.VoidYn,0) = 0
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingHistoryViewDetail_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingHistoryViewDetail_proc';

