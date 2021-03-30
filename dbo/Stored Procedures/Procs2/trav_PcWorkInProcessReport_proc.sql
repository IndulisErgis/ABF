
CREATE PROCEDURE dbo.trav_PcWorkInProcessReport_proc 
@FiscalYear smallint = 2010,
@FiscalPeriod smallint = 6
AS
BEGIN TRY
SET NOCOUNT ON

	--Time, Material, Expense and Other
	SELECT p.CustId, p.ProjectName AS ProjectId, d.PhaseId, d.TaskId, a.[Type], a.ExtCost AS Amount, a.GLAcctWIP AS GlAccount
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	WHERE p.[Type] = 1 AND a.[Status] BETWEEN 2 AND 4 AND a.[Type] BETWEEN 0 AND 3 AND [Source] <> 11--Job costing, posted, wip and billed, no po receipt
		AND (a.FiscalYear < @FiscalYear OR (a.FiscalYear = @FiscalYear AND a.FiscalPeriod <= @FiscalPeriod))
	UNION ALL 
	SELECT p.CustId, p.ProjectName AS ProjectId, d.PhaseId, d.TaskId, a.[Type], a.ExtIncome AS Amount, a.GLAcctWIP AS GlAccount
	FROM dbo.tblPcProjectDetail d INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId 
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	WHERE p.[Type] = 0 AND d.Billable = 1 AND d.FixedFee = 0 AND a.[Status] BETWEEN 2 AND 3 AND a.[Type] BETWEEN 0 AND 3 AND [Source] <> 11--Genearl, billable, non-fixed fee, posted, wip, no po receipt
		AND (a.FiscalYear < @FiscalYear OR (a.FiscalYear = @FiscalYear AND a.FiscalPeriod <= @FiscalPeriod))
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcWorkInProcessReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcWorkInProcessReport_proc';

