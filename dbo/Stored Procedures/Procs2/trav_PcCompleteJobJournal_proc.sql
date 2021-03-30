
CREATE PROCEDURE dbo.trav_PcCompleteJobJournal_proc 
AS
BEGIN TRY
SET NOCOUNT ON

	SELECT p.CustId, p.ProjectName AS ProjId, d.PhaseId, d.TaskId, a.Qty AS AntQty, a.ExtCost, 
		CASE a.Qty WHEN 0 THEN a.ExtCost ELSE a.ExtCost/a.Qty END AS UnitCost, 
		a.GLAcctCost AS GLAcctCOS, a.ActivityDate AS TransDate, a.AddnlDesc
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId
	WHERE a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 4 --Activity type is Time, Material, Expense, Other; Activity status is billed.
	
	SELECT p.CustId, p.ProjectName AS ProjId, d.PhaseId, d.TaskId, a.ExtIncome AS Amount,a.GLAcctIncome, a.AddnlDesc
	FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcProjectDetail d ON t.Id = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId
	WHERE a.[Type] = 6 AND a.[Status] = 2 --Activity type is Fixed Fee Billing; Activity status is posted.
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCompleteJobJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCompleteJobJournal_proc';

