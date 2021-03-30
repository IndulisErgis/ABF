
CREATE PROCEDURE [dbo].[trav_MrLaborTypesList_proc]

AS
SET NOCOUNT ON
BEGIN TRY

SELECT l.LaborTypeId, l.Descr, l.Notes, l.HourlyRate, l.PerPieceCost, l.ScheduleId,l.GLAcct1
	, l.MGID, l.CostGroupId, l.BillMethod, l.BillRate
FROM tblMrLabor l INNER JOIN #tmpLaborTypes t on l.LaborTypeId = t.LaborTypeId

SELECT l.LaborTypeId, l.EmployeeId
	, COALESCE(e.FirstName, '') + ' ' + COALESCE(e.MiddleInit, '') + ' ' + COALESCE(e.LastName, '') AS EmployeeName 
FROM dbo.tblMrLaborTypeEmployee l INNER JOIN #tmpLaborTypes t on t.LaborTypeId = l.LaborTypeId 
	LEFT JOIN dbo.tblSmEmployee e ON l.EmployeeId = e.EmployeeId
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrLaborTypesList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MrLaborTypesList_proc';

