
CREATE PROCEDURE [dbo].[trav_MbStandardCostAdjustment_Proc]

AS
SET NOCOUNT ON

BEGIN TRY

	SELECT a.ItemId, a.LocId, a.GLAccount, i.CostStd AS OriginalStdCost, a.UnitCost AS NewStdCost, TransDate 
	FROM dbo.tblInStandardCostAdjust a 
		LEFT JOIN dbo.tblInItemLoc i ON a.ItemId = i.ItemId AND a.LocId = i.LocId
		INNER JOIN #tmpItemLoc il ON a.ItemId = il.ItemId AND a.LocId = il.LocId
		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbStandardCostAdjustment_Proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_MbStandardCostAdjustment_Proc';

