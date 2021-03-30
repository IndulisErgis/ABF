
CREATE PROCEDURE dbo.trav_InPhysicalCount_PrepareBatch_proc 
@BatchId pBatchId
AS
DECLARE @WmYn bit
DECLARE @DefaultNoBin bit
BEGIN TRY

SELECT @WmYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'WmYn'
SELECT @DefaultNoBin = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'DefaultNoBin'
IF @WmYn IS NULL
BEGIN
	RAISERROR(90025,16,1)
END
IF @DefaultNoBin IS NULL
BEGIN
	RAISERROR(90025,16,1)
END
DECLARE 
@ItemIdFrom pItemID,
@ItemIdThru pItemID,
@LocIdFrom pLocID,
@LocIdThru pLocID,
@BinNumFrom nvarchar(10),
@BinNumThru nvarchar(10),
@ProductLineFrom nvarchar(12),
@ProductLineThru nvarchar(12),
@ABCClassFrom nvarchar(10),  
@ABCClassThru nvarchar(10),
@RptUom tinyint
--todo, user defined fields
SELECT @ItemIdFrom = ItemIdFrom, @ItemIdThru = ItemIdThru, 
       @LocIdFrom = LocIdFrom, @LocIdThru = LocIdThru, 
       @ProductLineFrom = ProductLineFrom, @ProductLineThru = ProductLineThru, 
       @ABCClassFrom = ABCClassFrom, @ABCClassThru = ABCClassThru,    
       @BinNumFrom = BinNumFrom, @BinNumThru = BinNumThru,
	   @RptUom = RptUom
FROM dbo.tblInPhysCountBatch 
WHERE BatchId = @BatchId

DELETE dbo.tblInPhysCountDetail 
FROM dbo.tblInPhysCount p INNER JOIN dbo.tblInPhysCountDetail 
ON p.SeqNum = dbo.tblInPhysCountDetail.SeqNum 
WHERE p.BatchId = @BatchId

DELETE dbo.tblInPhysCount WHERE BatchId = @BatchId

--Header
IF (@BinNumFrom IS NOT NULL OR @BinNumThru IS NOT NULL) --Use bin filter
BEGIN
	If @DefaultNoBin = 1
	BEGIN
		INSERT INTO dbo.tblInPhysCount (BatchId,ItemId,LocId,LotNum,ProductLine,DfltBinNum,CountedUom,CountedUomConvFactor, CF)
		SELECT @BatchId,i.ItemId,l.LocId,t.LotNum,i.ProductLine,l.DfltBinNum, p.Uom, p.ConvFactor, i.CF
		FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId 
			LEFT JOIN dbo.tblInItemLocLot t ON l.ItemId = t.ItemId AND l.LocId = t.LocId 
			Left JOIN dbo.tblInItemUomDflt u ON i.ItemId = u.ItemId AND u.DfltType = 1
			INNER JOIN dbo.tblInItemUom p ON i.ItemId = p.ItemId AND p.Uom = CASE WHEN @RptUom = 0 THEN ISNULL(u.Uom,i.UomDflt) ELSE i.UomBase END 
			LEFT JOIN dbo.trav_InItemOnHandLot_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId AND t.LotNum = q.LotNum
			WHERE (@ItemIdFrom IS NULL OR i.ItemId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR i.ItemId <= @ItemIdThru)
			AND (@LocIdFrom IS NULL OR l.LocId >= @LocIdFrom) AND (@LocIdThru IS NULL OR l.LocId <= @LocIdThru)
			AND (@ProductLineFrom IS NULL OR i.ProductLine >= @ProductLineFrom) AND (@ProductLineThru IS NULL OR i.ProductLine IS NULL OR i.ProductLine <= @ProductLineThru)
			AND (@ABCClassFrom IS NULL OR l.ABCClass >= @ABCClassFrom) AND (@ABCClassThru IS NULL OR l.ABCClass IS NULL OR l.ABCClass <= @ABCClassThru)
			AND (@BinNumFrom IS NULL OR l.DfltBinNum >= @BinNumFrom) AND (@BinNumThru IS NULL OR l.DfltBinNum IS NULL OR l.DfltBinNum <= @BinNumThru)
			AND (i.LottedYn = 0 OR (i.LottedYn = 1 AND t.LotNum IS NOT NULL AND NOT (t.LotStatus = 2 AND ISNULL(q.QtyOnHand,0) = 0))) 
			AND i.ItemType < 3 AND i.ItemStatus < 4 AND i.KittedYn = 0
	END
	ELSE
	BEGIN
		INSERT INTO dbo.tblInPhysCount (BatchId,ItemId,LocId,LotNum,ProductLine,DfltBinNum,CountedUom,CountedUomConvFactor, CF)
		SELECT @BatchId,i.ItemId,l.LocId,t.LotNum,i.ProductLine,l.DfltBinNum, p.Uom, p.ConvFactor, i.CF
		FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId 
			LEFT JOIN dbo.tblInItemLocLot t ON l.ItemId = t.ItemId AND l.LocId = t.LocId 
			Left JOIN dbo.tblInItemUomDflt u ON i.ItemId = u.ItemId AND u.DfltType = 1
			INNER JOIN dbo.tblInItemUom p ON i.ItemId = p.ItemId AND p.Uom = CASE WHEN @RptUom = 0 THEN ISNULL(u.Uom,i.UomDflt) ELSE i.UomBase END 
			LEFT JOIN dbo.trav_InItemOnHandLot_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId AND t.LotNum = q.LotNum
			WHERE (@ItemIdFrom IS NULL OR i.ItemId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR i.ItemId <= @ItemIdThru)
			AND (@LocIdFrom IS NULL OR l.LocId >= @LocIdFrom) AND (@LocIdThru IS NULL OR l.LocId <= @LocIdThru)
			AND (@ProductLineFrom IS NULL OR i.ProductLine >= @ProductLineFrom) AND (@ProductLineThru IS NULL OR i.ProductLine IS NULL OR i.ProductLine <= @ProductLineThru)
			AND (@ABCClassFrom IS NULL OR l.ABCClass >= @ABCClassFrom) AND (@ABCClassThru IS NULL OR l.ABCClass IS NULL OR l.ABCClass <= @ABCClassThru)
			AND (i.LottedYn = 0 OR (i.LottedYn = 1 AND t.LotNum IS NOT NULL AND NOT (t.LotStatus = 2 AND ISNULL(q.QtyOnHand,0) = 0))) 
			AND i.ItemType < 3 AND i.ItemStatus < 4 AND i.KittedYn = 0
	END
END
ELSE
BEGIN
	If @DefaultNoBin = 1
	BEGIN
		INSERT INTO dbo.tblInPhysCount (BatchId,ItemId,LocId,LotNum,ProductLine,DfltBinNum,CountedUom,CountedUomConvFactor, CF)
		SELECT @BatchId,i.ItemId,l.LocId,t.LotNum,i.ProductLine,l.DfltBinNum, p.Uom, p.ConvFactor, i.CF
		FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId 
			LEFT JOIN dbo.tblInItemLocLot t ON l.ItemId = t.ItemId AND l.LocId = t.LocId 
			Left JOIN dbo.tblInItemUomDflt u ON i.ItemId = u.ItemId AND u.DfltType = 1
			INNER JOIN dbo.tblInItemUom p ON i.ItemId = p.ItemId AND p.Uom = CASE WHEN @RptUom = 0 THEN ISNULL(u.Uom,i.UomDflt) ELSE i.UomBase END 
			LEFT JOIN dbo.tblInPhysCount c ON l.ItemId = c.ItemId AND l.LocID = c.LocId 
			LEFT JOIN dbo.trav_InItemOnHandLot_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId AND t.LotNum = q.LotNum
			WHERE c.LocId IS NULL --exclude item/locations that already exist in the Physical counts table
			AND (@ItemIdFrom IS NULL OR i.ItemId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR i.ItemId <= @ItemIdThru)
			AND (@LocIdFrom IS NULL OR l.LocId >= @LocIdFrom) AND (@LocIdThru IS NULL OR l.LocId <= @LocIdThru)
			AND (@ProductLineFrom IS NULL OR i.ProductLine >= @ProductLineFrom) AND (@ProductLineThru IS NULL OR i.ProductLine IS NULL OR i.ProductLine <= @ProductLineThru)
			AND (@ABCClassFrom IS NULL OR l.ABCClass >= @ABCClassFrom) AND (@ABCClassThru IS NULL OR l.ABCClass IS NULL OR l.ABCClass <= @ABCClassThru)
			AND (@BinNumFrom IS NULL OR l.DfltBinNum >= @BinNumFrom) AND (@BinNumThru IS NULL OR l.DfltBinNum IS NULL OR l.DfltBinNum <= @BinNumThru)
			AND (i.LottedYn = 0 OR (i.LottedYn = 1 AND t.LotNum IS NOT NULL AND NOT (t.LotStatus = 2 AND ISNULL(q.QtyOnHand,0) = 0))) 
			AND i.ItemType < 3 AND i.ItemStatus < 4 AND i.KittedYn = 0
	END
	ELSE
	BEGIN
		INSERT INTO dbo.tblInPhysCount (BatchId,ItemId,LocId,LotNum,ProductLine,DfltBinNum,CountedUom,CountedUomConvFactor, CF)
		SELECT @BatchId,i.ItemId,l.LocId,t.LotNum,i.ProductLine,l.DfltBinNum, p.Uom, p.ConvFactor, i.CF
		FROM dbo.tblInItem i INNER JOIN dbo.tblInItemLoc l ON i.ItemId = l.ItemId 
			LEFT JOIN dbo.tblInItemLocLot t ON l.ItemId = t.ItemId AND l.LocId = t.LocId 
			Left JOIN dbo.tblInItemUomDflt u ON i.ItemId = u.ItemId AND u.DfltType = 1
			INNER JOIN dbo.tblInItemUom p ON i.ItemId = p.ItemId AND p.Uom = CASE WHEN @RptUom = 0 THEN ISNULL(u.Uom,i.UomDflt) ELSE i.UomBase END 
			LEFT JOIN dbo.tblInPhysCount c ON l.ItemId = c.ItemId AND l.LocID = c.LocId 
			LEFT JOIN dbo.trav_InItemOnHandLot_view q ON t.ItemId = q.ItemId AND t.LocId = q.LocId AND t.LotNum = q.LotNum
		WHERE c.LocId IS NULL --exclude item/locations that already exist in the Physical counts table
			AND (@ItemIdFrom IS NULL OR i.ItemId >= @ItemIdFrom) AND (@ItemIdThru IS NULL OR i.ItemId <= @ItemIdThru)
			AND (@LocIdFrom IS NULL OR l.LocId >= @LocIdFrom) AND (@LocIdThru IS NULL OR l.LocId <= @LocIdThru)
			AND (@ProductLineFrom IS NULL OR i.ProductLine >= @ProductLineFrom) AND (@ProductLineThru IS NULL OR i.ProductLine IS NULL OR i.ProductLine <= @ProductLineThru)
			AND (@ABCClassFrom IS NULL OR l.ABCClass >= @ABCClassFrom) AND (@ABCClassThru IS NULL OR l.ABCClass IS NULL OR l.ABCClass <= @ABCClassThru)
			AND (i.LottedYn = 0 OR (i.LottedYn = 1 AND t.LotNum IS NOT NULL AND NOT (t.LotStatus = 2 AND ISNULL(q.QtyOnHand,0) = 0))) 
			AND i.ItemType < 3 AND i.ItemStatus < 4 AND i.KittedYn = 0
	END
END

--detail
If @WmYn = 0
BEGIN
	--Regular item bin numbers
	INSERT INTO dbo.tblInPhysCountDetail(SeqNum, SerNum, ExtLocAId, CountedUom)
	SELECT c.SeqNum,NULL, b.BinNum,c.CountedUom
	FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId 
		INNER JOIN dbo.tblInItemLocBin b ON c.ItemId = b.ItemId AND c.LocId = b.LocId
		LEFT JOIN (SELECT h.ItemId, h.LocId, d.ExtLocAId FROM dbo.tblInPhysCount h INNER JOIN dbo.tblInPhysCountDetail d ON h.SeqNum = d.SeqNum) e 
			ON c.ItemId = e.ItemId AND c.LocId = e.LocId AND b.BinNum = e.ExtLocAId
	WHERE c.BatchId = @BatchId AND i.ItemType = 1 AND e.ItemId IS NULL
		AND @DefaultNoBin = 0
		AND (@BinNumFrom IS NULL OR b.BinNum >= @BinNumFrom) AND (@BinNumThru IS NULL OR b.BinNum <= @BinNumThru)

	--Serial numbers
		INSERT INTO dbo.tblInPhysCountDetail(SeqNum, SerNum,ExtLocAId, CountedUom)
		SELECT c.SeqNum,s.SerNum,CASE WHEN @DefaultNoBin = 1 THEN c.DfltBinNum ELSE NULL END,c.CountedUom
		FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInItemSer s ON c.ItemId = s.ItemId AND c.LocId = s.LocId AND (c.LotNum = s.LotNum OR (c.LotNum IS NULL AND s.LotNum IS NULL))
		WHERE c.BatchId = @BatchId AND s.SerNumStatus IN (1, 8)

END
ELSE
BEGIN
	--regular item with extended locations
	INSERT INTO dbo.tblInPhysCountDetail(SeqNum, SerNum, ExtLocAId, ExtLocBId, CountedUom)
	SELECT c.SeqNum,NULL,n.ExtLocAId,n.ExtLocBId,c.CountedUom
	FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId 
		INNER JOIN (SELECT e.ItemId, e.LocId, e.LotNum, a.ExtLocID AS ExtLocAId, b.ExtLocID AS ExtLocBId
			FROM dbo.tblInQtyOnHand_Ext e LEFT JOIN dbo.tblWmExtLoc a ON e.ExtLocA = a.Id 
				LEFT JOIN dbo.tblWmExtLoc b ON e.ExtLocB = b.Id 
			WHERE (e.ExtLocA IS NOT NULL OR e.ExtLocB IS NOT NULL) AND			
				NOT ((e.ExtLocA IS NOT NULL AND a.Id IS NULL) OR (e.ExtLocB IS NOT NULL AND b.Id IS NULL))--Exclude invalid extended location keys 
			GROUP BY e.ItemId, e.LocId, e.LotNum, a.ExtLocID, b.ExtLocID) n 
			ON c.ItemId = n.ItemId AND c.LocId = n.LocId AND (c.LotNum = n.LotNum OR (c.LotNum IS NULL AND n.LotNum IS NULL))
	WHERE c.BatchId = @BatchId 
		AND (@BinNumFrom IS NULL OR n.ExtLocAId >= @BinNumFrom) AND (@BinNumThru IS NULL OR n.ExtLocAId IS NULL OR n.ExtLocAId <= @BinNumThru)
		
	--serial numbers
	INSERT INTO dbo.tblInPhysCountDetail(SeqNum, SerNum, ExtLocAId, ExtLocBId, CountedUom)
	SELECT c.SeqNum,s.SerNum,a.ExtLocID AS ExtLocAId, b.ExtLocID AS ExtLocBId,c.CountedUom
	FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInItemSer s ON c.ItemId = s.ItemId AND c.LocId = s.LocId AND (c.LotNum = s.LotNum OR (c.LotNum IS NULL AND s.LotNum IS NULL))
		LEFT JOIN dbo.tblWmExtLoc a ON s.ExtLocA = a.Id 
		LEFT JOIN dbo.tblWmExtLoc b ON s.ExtLocB = b.Id
	WHERE c.BatchId = @BatchId AND s.SerNumStatus IN (1, 8)
		AND (@BinNumFrom IS NULL OR a.ExtLocID >= @BinNumFrom) AND (@BinNumThru IS NULL OR a.ExtLocID IS NULL OR a.ExtLocID <= @BinNumThru)

END

IF ((@BinNumFrom IS NOT NULL OR @BinNumThru IS NOT NULL) AND @DefaultNoBin = 0) --Use bin filter
BEGIN
	DELETE dbo.tblInPhysCount 
	WHERE BatchId = @BatchId AND NOT EXISTS(SELECT * FROM dbo.tblInPhysCountDetail WHERE SeqNum = dbo.tblInPhysCount.SeqNum)
END


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InPhysicalCount_PrepareBatch_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InPhysicalCount_PrepareBatch_proc';

