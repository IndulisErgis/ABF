
CREATE PROCEDURE dbo.trav_PcTimeTicketJournal_proc 
@PrecCurr smallint
AS
BEGIN TRY
SET NOCOUNT ON

	SELECT m.BatchId, m.Id AS TransId, m.TransDate, p.CustId, c.CustName, p.ProjectName AS ProjId, d.PhaseId, 
		d.TaskId, m.Qty, ROUND(m.Qty * m.UnitCost,@PrecCurr) AS ExtCost, ROUND(m.Qty * m.BillingRate,@PrecCurr) AS Amount,
		m.[Description], m.[AddnlDesc], m.RateId AS BillingRateId, m.BillingRate, m.Pieces, m.StateCode, m.LocalCode,
		m.DepartmentId, m.LaborClass, m.EarnCode, m.SUIState, m.SeqNo, m.EmployeeId,
		COALESCE (LastName, '') + ', ' + COALESCE (FirstName, '')  + ' ' + COALESCE (MiddleInit, '') AS EmployeeName
	FROM #tmpTimeTicketList t INNER JOIN dbo.tblPcTimeTicket m ON t.Id = m.Id
		INNER JOIN dbo.tblPcProjectDetail d ON m.ProjectDetailId = d.Id
		INNER JOIN dbo.tblPcProject p ON d.ProjectId = p.Id 
		LEFT JOIN dbo.tblArCust c ON p.CustId = c.CustId
		LEFT JOIN dbo.tblSmEmployee e ON m.EmployeeId = e.EmployeeId
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTimeTicketJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcTimeTicketJournal_proc';

