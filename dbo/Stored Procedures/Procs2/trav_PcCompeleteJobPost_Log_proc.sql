
CREATE PROCEDURE dbo.trav_PcCompeleteJobPost_Log_proc
AS
BEGIN TRY
	--Income
		SELECT p.CustId, p.ProjectName AS ProjId, d.PhaseId, d.TaskId, a.ExtIncome AS Amount, 
			a.GLAcctFixedFeeBilling AS BillingAcct, a.GLAcctIncome AS IncomeAcct
		FROM #PostTransList t INNER JOIN dbo.tblPcProjectDetail d ON t.TransId = d.Id
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId
		WHERE a.[Type] = 6 AND a.[Status] = 2 AND a.ExtIncome <> 0--Activity type is Fixed Fee Billing; Activity status is posted.

	--Cost 
		SELECT p.CustId, p.ProjectName AS ProjId, d.PhaseId, d.TaskId, a.ExtCost, 
			a.GLAcctCost AS GLAcctCOS, a.GLAcctWIP
		FROM #PostTransList t INNER JOIN dbo.tblPcProjectDetail d ON t.TransId = d.Id
			INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
			INNER JOIN dbo.tblPcActivity a ON d.Id = a.ProjectDetailId
		WHERE a.[Type] BETWEEN 0 AND 3 AND a.[Status] = 4 AND a.ExtCost <> 0--Activity type is Time, Material, Expense, Other; Activity status is billed.	
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCompeleteJobPost_Log_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcCompeleteJobPost_Log_proc';

