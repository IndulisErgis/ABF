
CREATE PROCEDURE dbo.trav_PcAdjustmentJournal_proc 
AS
BEGIN TRY
SET NOCOUNT ON

SELECT p.CustId, p.ProjectName AS ProjId, d.PhaseId, d.TaskId, a.FiscalPeriod, a.FiscalYear, a.[Type], a.TransDate,
	a.AddnlDesc, CASE a.IncDec WHEN 0 THEN 1 ELSE -1 END * a.Qty AS ActQty, CASE a.IncDec WHEN 0 THEN 1 ELSE -1 END * a.ExtCost AS ActExtCost, 
	CASE a.IncDec WHEN 0 THEN 1 ELSE -1 END * a.ExtIncome AS ActExtIncome, a.[Description], c.CustName
FROM #tmpProjectDetailList t INNER JOIN dbo.tblPcAdjustment a ON t.ProjectDetailId = a.ProjectDetailId
	INNER JOIN dbo.tblPcProjectDetail d ON t.ProjectDetailId = d.Id
	INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
	LEFT Join dbo.tblArCust c ON p.CustId = c.CustId
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcAdjustmentJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcAdjustmentJournal_proc';

