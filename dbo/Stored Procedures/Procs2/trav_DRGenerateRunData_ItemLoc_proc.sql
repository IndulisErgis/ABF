
CREATE PROCEDURE dbo.trav_DRGenerateRunData_ItemLoc_proc
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE	@RunId pPostRun

	--Retrieve global values
	SELECT @RunId = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'RunId'
	
	IF @RunId IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END


	--capture current on hand qty for non-serialized and serialized items
	-- Active - non-kitted - non-service items
	INSERT INTO dbo.tblDrRunItemLoc (RunId, ItemId, LocId, QtyOnHand)
	SELECT @RunId, i.ItemId, l.LocId, SUM(ISNULL(tmp.QtyOnHand, 0))
	FROM dbo.tblInItem i
	INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId
	LEFT JOIN (
		SELECT ItemId, LocId, QtyOnHand FROM dbo.trav_InItemOnHand_view
		UNION ALL
		SELECT ItemId, LocId, (QtyOnHand - QtyInUse) QtyOnHand FROM dbo.trav_InItemOnHandSer_view 
	) tmp
	ON l.ItemId = tmp.ItemId AND l.LocId = tmp.LocId
	WHERE i.ItemType <> 3 AND i.ItemStatus = 1 AND l.ItemLocStatus = 1 AND i.KittedYN = 0 
	GROUP BY i.ItemId, l.LocId

		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_ItemLoc_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_DRGenerateRunData_ItemLoc_proc';

