
CREATE PROCEDURE dbo.trav_InUpdatePerpetual_NewLotExtended_proc 
@BatchId pBatchID
AS
DECLARE @DefaultNoBin bit
BEGIN TRY

SELECT @DefaultNoBin = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'DefaultNoBin'

IF @DefaultNoBin IS NULL
BEGIN
	RAISERROR(90025,16,1)
END

--New item/location/bin
If @DefaultNoBin = 1  
BEGIN
	INSERT INTO dbo.tblInItemLocBin ( ItemId, LocId, BinNum )
	SELECT c.ItemId, c.LocId, c.DfltBinNum
	FROM dbo.tblInPhysCount c 
		LEFT JOIN dbo.tblInItemLocBin b ON c.ItemId = b.ItemId AND c.LocId = b.LocId 
		INNER JOIN dbo.tblInItem i ON  c.ItemId= i.ItemId
	WHERE c.BatchId = @BatchId
	 AND b.BinNum IS NULL AND i.ItemType = 1 AND c.DfltBinNum IS NOT NULL
	GROUP BY c.ItemId, c.LocId, c.DfltBinNum

	/* Update bin */
	UPDATE dbo.tblInItemLocBin 
		SET LastCountBatchId = b.BatchId, LastCountDate = b.CountDate
		, LastCountTagNum = c.TagNum, LastCountUom = c.CountedUOM
		, LastCountQty = c.QtyCounted
	FROM dbo.tblInPhysCountBatch b INNER JOIN dbo.tblInPhysCount c ON b.BatchId = c.BatchId 
		INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId
		INNER JOIN dbo.tblInItemLocBin ON c.ItemId = dbo.tblInItemLocBin.ItemId AND 
			c.LocId = dbo.tblInItemLocBin.LocId AND c.DfltBinNum = dbo.tblInItemLocBin.BinNum
	WHERE b.BatchId = @BatchId AND i.ItemType = 1
END
ELSE
BEGIN
	INSERT INTO dbo.tblInItemLocBin ( ItemId, LocId, BinNum )
	SELECT c.ItemId, c.LocId, d.ExtLocAId
	FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInPhysCountDetail d ON c.SeqNum = d.SeqNum
		LEFT JOIN dbo.tblInItemLocBin b ON c.ItemId = b.ItemId AND c.LocId = b.LocId AND d.ExtLocAId = b.BinNum
	WHERE c.BatchId = @BatchId AND d.ExtLocAId IS NOT NULL AND b.BinNum IS NULL
	GROUP BY c.ItemId, c.LocId, d.ExtLocAId

END

/* Add New Lots */
INSERT INTO tblInItemLocLot ( ItemId, LocId, LotNum, LotStatus, InitialDate )
SELECT c.ItemId, c.LocId, c.LotNum, 1, MIN(b.CountDate) 
FROM dbo.tblInPhysCountBatch b INNER JOIN dbo.tblInPhysCount c ON b.BatchId = c.BatchId 
WHERE b.BatchId = @BatchId AND NOT EXISTS (SELECT * FROM dbo.tblInItemLocLot i WHERE i.ItemId = c.ItemId AND i.LocId = c.LocId AND i.LotNum = c.LotNum) 
	AND c.LotNum IS NOT NULL
GROUP BY ItemId, LocId, LotNum 

/* Update bin */
UPDATE dbo.tblInItemLocBin 
	SET LastCountBatchId = b.BatchId, LastCountDate = b.CountDate
	, LastCountTagNum = d.TagNum, LastCountUom = d.CountedUOM
	, LastCountQty = d.QtyCounted
FROM dbo.tblInPhysCountBatch b INNER JOIN dbo.tblInPhysCount c ON b.BatchId = c.BatchId 
	INNER JOIN dbo.tblInPhysCountDetail d ON c.SeqNum = d.SeqNum 
	INNER JOIN dbo.tblInItemLocBin ON c.ItemId = dbo.tblInItemLocBin.ItemId AND 
		c.LocId = dbo.tblInItemLocBin.LocId AND d.ExtLocAId = dbo.tblInItemLocBin.BinNum
WHERE b.BatchId = @BatchId 

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdatePerpetual_NewLotExtended_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InUpdatePerpetual_NewLotExtended_proc';

