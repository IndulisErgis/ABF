
CREATE PROCEDURE dbo.trav_InUpdatePerpetual_ExtendedQty_proc
@SeqNum int
AS
BEGIN TRY
	DECLARE @PrecQty tinyint
	
	SELECT @PrecQty = Cast([Value] AS tinyint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
	
	IF @PrecQty IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	INSERT INTO dbo.tblInQtyOnHand_Ext ([ItemId], [LocId], [LotNum], [ExtLocA], [ExtLocB], [Qty])
	SELECT c.ItemId,c.LocId,c.LotNum,a.Id,b.Id,
		ROUND(d.QtyCounted * u.ConvFactor, @PrecQty) - d.QtyFrozen
	FROM dbo.tblInPhysCountDetail d INNER JOIN dbo.tblInPhysCount c ON d.SeqNum = c.SeqNum 
		INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId
		INNER JOIN dbo.tblInItemUom u ON c.ItemId = u.ItemId AND d.CountedUom = u.Uom 
		LEFT JOIN dbo.tblWmExtLoc a ON c.LocId = a.LocID AND d.ExtLocAId = a.ExtLocID AND a.[Type] = 0 
		LEFT JOIN dbo.tblWmExtLoc b ON d.ExtLocBId = b.ExtLocID AND b.[Type] = 1
	WHERE d.DtlSeqNum = @SeqNum	
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdatePerpetual_ExtendedQty_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdatePerpetual_ExtendedQty_proc';

