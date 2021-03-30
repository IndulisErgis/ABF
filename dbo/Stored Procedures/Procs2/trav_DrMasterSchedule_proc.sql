
Create PROCEDURE dbo.trav_DrMasterSchedule_proc
AS
SET NOCOUNT ON
BEGIN TRY

	SELECT h.AssemblyId, h.LocId, h.UOM, i.Descr, d.ProdDate, d.Qty, d.Notes 
	FROM #tblDrMstrSched t INNER JOIN   dbo.tblDrMstrSched h (NOLOCK) ON t.id=h.id  
	INNER JOIN dbo.tblDrMstrSchedDtl d 	ON h.id = d.MstrSchedId and t.ProdDate=d.ProdDate
	LEFT OUTER JOIN   dbo.tblInItem i ON h.AssemblyId = i.ItemId
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrMasterSchedule_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DrMasterSchedule_proc';

