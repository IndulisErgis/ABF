
CREATE PROCEDURE dbo.trav_InPhysicalCount_FreezeQty_proc 
@BatchId pBatchId
AS
DECLARE @WmYn bit, @PrecQty smallint, @PrecCurr smallint, @CostingMethod smallint, @ExcludePickedQuantity bit
BEGIN TRY

SELECT @WmYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'WmYn'
SELECT @PrecQty = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecQty'
SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
SELECT @CostingMethod = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'CostingMethod'
SELECT @ExcludePickedQuantity = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ExcludePickedQuantity'

IF @WmYn IS NULL OR @PrecQty IS NULL OR @PrecCurr IS NULL OR @CostingMethod IS NULL OR @ExcludePickedQuantity IS NULL
BEGIN
	RAISERROR(90025,16,1)
END

--Serilized item
UPDATE dbo.tblInPhysCountDetail SET QtyFrozen = CASE WHEN p.ItemId IS NULL THEN 1 ELSE 0 END, 
	CostFrozen = CASE WHEN p.ItemId IS NULL THEN s.CostUnit ELSE 0 END
FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInPhysCountDetail ON c.SeqNum = dbo.tblInPhysCountDetail.SeqNum 
	INNER JOIN dbo.tblInItemSer s ON c.ItemId = s.ItemId AND dbo.tblInPhysCountDetail.SerNum = s.SerNum 
	LEFT JOIN (SELECT d.ItemId, e.SerNum
		FROM dbo.tblSoTransHeader h INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransID
			INNER JOIN dbo.tblSoTransSer e ON d.TransId = e.TransId AND d.EntryNum = e.EntryNum 
		WHERE h.TransType = 5 AND h.VoidYn = 0) p ON s.ItemId = p.ItemId AND s.SerNum = p.SerNum
	WHERE c.BatchId = @BatchId AND s.SerNumStatus IN (1, 8)

If @WmYn = 0
BEGIN
	--Null bin in the header
	UPDATE dbo.tblInPhysCount SET QtyFrozen = q.QtyOnHand
	From dbo.tblInPhysCount INNER JOIN dbo.trav_InItemOnHandLot_view q 
		ON dbo.tblInPhysCount.ItemId = q.ItemId And dbo.tblInPhysCount.LocId = q.LocId And (dbo.tblInPhysCount.LotNum = q.LotNum OR (dbo.tblInPhysCount.LotNum IS NULL AND q.LotNum IS NULL)) 
		INNER JOIN dbo.tblInItemLoc l ON q.ItemId = l.ItemId And q.LocId = l.LocId 
	WHERE dbo.tblInPhysCount.BatchId = @BatchId
END
ELSE
BEGIN
	--Null extended locaion in the header
	UPDATE dbo.tblInPhysCount SET QtyFrozen = q.QtyOnHand
	FROM dbo.tblInPhysCount INNER JOIN 
	(SELECT  ItemId,LocId,LotNum,SUM(QtyOnHand) AS QtyOnHand FROM 
		(SELECT ItemId,LocId,LotNum,NULL AS ExtLocAId, NULL AS ExtLocBId, SUM(Qty - InvoicedQty - RemoveQty) AS QtyOnHand
		 FROM dbo.tblInQtyOnHand GROUP BY ItemId,LocId,LotNum
		 UNION ALL
		 SELECT e.ItemId, e.LocId, e.LotNum, NULl AS ExtLocAId, NULL AS ExtLocBId, -SUM(e.Qty)  AS QtyOnHand
		 FROM dbo.tblInQtyOnHand_Ext e LEFT JOIN dbo.tblWmExtLoc a ON e.ExtLocA = a.Id 
						LEFT JOIN dbo.tblWmExtLoc b ON e.ExtLocB = b.Id 
		  WHERE (e.ExtLocA IS NOT NULL OR e.ExtLocB IS NOT NULL) AND			
			NOT ((e.ExtLocA IS NOT NULL AND a.Id IS NULL) OR (e.ExtLocB IS NOT NULL AND b.Id IS NULL))--Exclude invalid extended location keys 
		  GROUP BY e.ItemId, e.LocId, e.LotNum 
		  UNION ALL
		  --null bin/container
		  SELECT d.ItemId, d.LocId, e.LotNum, NULL AS ExtLocAId, NULL AS ExtLocBId, -SUM(ROUND(e.QtyFilled * u.ConvFactor, @PrecQty)) QtyPicked
		  FROM dbo.tblSoTransHeader h INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransID
			INNER JOIN dbo.tblSoTransDetailExt e ON d.TransId = e.TransId AND d.EntryNum = e.EntryNum 
			INNER JOIN dbo.tblInItemUom u ON d.ItemId = u.ItemId AND d.UnitsSell = u.Uom 
		  WHERE @ExcludePickedQuantity = 1 AND h.TransType = 5 AND h.VoidYn = 0 AND e.QtyFilled <> 0 AND e.ExtLocA IS NULL AND e.ExtLocB IS NULL
		  GROUP BY d.ItemId, d.LocId, e.LotNum
		  UNION ALL
		  --bin/container picked but not ever used
		  SELECT d.ItemId, d.LocId, e.LotNum, NULL AS ExtLocAId, NULL AS ExtLocBId, -SUM(ROUND(e.QtyFilled * u.ConvFactor, @PrecQty)) QtyPicked
		  FROM dbo.tblSoTransHeader h INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransID
			INNER JOIN dbo.tblSoTransDetailExt e ON d.TransId = e.TransId AND d.EntryNum = e.EntryNum 
			INNER JOIN dbo.tblInItemUom u ON d.ItemId = u.ItemId AND d.UnitsSell = u.Uom 
			LEFT JOIN (SELECT e.ItemId, e.LocId, e.LotNum, e.ExtLocA, e.ExtLocB
			FROM dbo.tblInQtyOnHand_Ext e WHERE e.ExtLocA IS NOT NULL OR e.ExtLocB IS NOT NULL 
			GROUP BY e.ItemId, e.LocId, e.LotNum, e.ExtLocA, e.ExtLocB) n 
			ON d.ItemId = n.ItemId AND d.LocId = n.LocId AND ISNULL(e.LotNum,'') = ISNULL(n.LotNum,'') 
				 AND ISNULL(e.ExtLocA,0) = ISNULL(n.ExtLocA,0) AND ISNULL(e.ExtLocB,0) = ISNULL(n.ExtLocB,0)
		  WHERE @ExcludePickedQuantity = 1 AND h.TransType = 5 AND h.VoidYn = 0 AND e.QtyFilled <> 0 AND (e.ExtLocA IS NOT NULL OR e.ExtLocB IS NOT NULL) 
			AND n.ItemId IS NULL
		  GROUP BY d.ItemId, d.LocId, e.LotNum  
		) l
		GROUP BY ItemId,LocId,LotNum) q
		ON dbo.tblInPhysCount.ItemId = q.ItemId And dbo.tblInPhysCount.LocId = q.LocId And (dbo.tblInPhysCount.LotNum = q.LotNum OR (dbo.tblInPhysCount.LotNum IS NULL AND q.LotNum IS NULL)) 
		INNER JOIN dbo.tblInItemLoc l ON dbo.tblInPhysCount.ItemId = l.ItemId And dbo.tblInPhysCount.LocId = l.LocId
	WHERE dbo.tblInPhysCount.BatchId = @BatchId

	--extended locations in the detail
	UPDATE dbo.tblInPhysCountDetail SET QtyFrozen = q.QtyOnHand
	FROM dbo.tblInPhysCount c INNER JOIN tblInPhysCountDetail ON c.SeqNum = dbo.tblInPhysCountDetail.SeqNum 
		INNER JOIN dbo.tblInItemLoc l ON c.ItemId = l.ItemId And c.LocId = l.LocId
		INNER JOIN (
			SELECT ItemId, LocId, LotNum, ExtLocAId, ExtLocBId, SUM(QtyOnHand) AS QtyOnHand 
			FROM
			(SELECT e.ItemId, e.LocId, e.LotNum, a.ExtLocID AS ExtLocAId, b.ExtLocID AS ExtLocBId, SUM(e.Qty) AS QtyOnHand
			FROM dbo.tblInQtyOnHand_Ext e LEFT JOIN dbo.tblWmExtLoc a ON e.ExtLocA = a.Id 
				LEFT JOIN dbo.tblWmExtLoc b ON e.ExtLocB = b.Id 
			WHERE (e.ExtLocA IS NOT NULL OR e.ExtLocB IS NOT NULL) AND			
				NOT ((e.ExtLocA IS NOT NULL AND a.Id IS NULL) OR (e.ExtLocB IS NOT NULL AND b.Id IS NULL))--Exclude invalid extended location keys 
			GROUP BY e.ItemId, e.LocId, e.LotNum, a.ExtLocID, b.ExtLocID
		    UNION ALL
		    SELECT d.ItemId, d.LocId, e.LotNum, a.ExtLocID AS ExtLocAId, b.ExtLocID AS ExtLocBId, -SUM(ROUND(e.QtyFilled * u.ConvFactor, @PrecQty)) QtyPicked
		    FROM dbo.tblSoTransHeader h INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransID
			  INNER JOIN dbo.tblSoTransDetailExt e ON d.TransId = e.TransId AND d.EntryNum = e.EntryNum 
			  INNER JOIN dbo.tblInItemUom u ON d.ItemId = u.ItemId AND d.UnitsSell = u.Uom 
			  LEFT JOIN dbo.tblWmExtLoc a ON e.ExtLocA = a.Id 
			  LEFT JOIN dbo.tblWmExtLoc b ON e.ExtLocB = b.Id 
		    WHERE @ExcludePickedQuantity = 1 AND h.TransType = 5 AND h.VoidYn = 0 AND e.QtyFilled <> 0 AND (e.ExtLocA IS NOT NULL OR e.ExtLocB IS NOT NULL)
		    GROUP BY d.ItemId, d.LocId, e.LotNum, a.ExtLocID, b.ExtLocID) l			
			GROUP BY ItemId, LocId, LotNum, ExtLocAId, ExtLocBId
			) q
		ON c.ItemId = q.ItemId And c.LocId = q.LocId And (c.LotNum = q.LotNum OR (c.LotNum IS NULL AND q.LotNum IS NULL)) 
			AND (dbo.tblInPhysCountDetail.ExtLocAId = q.ExtLocAId OR (dbo.tblInPhysCountDetail.ExtLocAId IS NULL AND q.ExtLocAId IS NULL)) 
			AND (dbo.tblInPhysCountDetail.ExtLocBId = q.ExtLocBId OR (dbo.tblInPhysCountDetail.ExtLocBId IS NULL AND q.ExtLocBId IS NULL)) 
	WHERE c.BatchId = @BatchId
END

UPDATE dbo.tblInPhysCount SET TotalQtyFrozen = QtyFrozen + ISNULL(d.QtyFrozenDetail,0)
FROM dbo.tblInPhysCount LEFT JOIN 
	(SELECT SeqNum, SUM(QtyFrozen) QtyFrozenDetail FROM dbo.tblInPhysCountDetail GROUP BY SeqNum) d
		ON dbo.tblInPhysCount.SeqNum = d.SeqNum
WHERE dbo.tblInPhysCount.BatchId = @BatchId

--Update frozen cost
IF (@CostingMethod = 2) --Average cost
BEGIN
	UPDATE dbo.tblInPhysCount SET CostFrozen = ROUND(TotalQtyFrozen * l.CostAvg,@PrecCurr)
	From dbo.tblInPhysCount INNER JOIN dbo.tblInItemLoc l ON dbo.tblInPhysCount.ItemId = l.ItemId And dbo.tblInPhysCount.LocId = l.LocId 
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
	WHERE dbo.tblInPhysCount.BatchId = @BatchId AND i.ItemType = 1
END
ELSE IF (@CostingMethod = 3) --Standard cost
BEGIN
	UPDATE dbo.tblInPhysCount SET CostFrozen = ROUND(TotalQtyFrozen * l.CostStd,@PrecCurr)
	From dbo.tblInPhysCount INNER JOIN dbo.tblInItemLoc l ON dbo.tblInPhysCount.ItemId = l.ItemId And dbo.tblInPhysCount.LocId = l.LocId 
		INNER JOIN dbo.tblInItem i ON l.ItemId = i.ItemId
	WHERE dbo.tblInPhysCount.BatchId = @BatchId AND i.ItemType = 1
END
ELSE --LIFO/FIFO
BEGIN
	UPDATE dbo.tblInPhysCount SET CostFrozen = CASE WHEN q.QtyOnHand = 0 THEN 0 ELSE ROUND(TotalQtyFrozen * q.Cost/ q.QtyOnHand, @PrecCurr) END
	From dbo.tblInPhysCount INNER JOIN dbo.trav_InItemOnHandLot_view q 
		ON dbo.tblInPhysCount.ItemId = q.ItemId And dbo.tblInPhysCount.LocId = q.LocId And (dbo.tblInPhysCount.LotNum = q.LotNum OR (dbo.tblInPhysCount.LotNum IS NULL AND q.LotNum IS NULL)) 
		INNER JOIN dbo.tblInItemLoc l ON q.ItemId = l.ItemId And q.LocId = l.LocId 
	WHERE dbo.tblInPhysCount.BatchId = @BatchId
END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InPhysicalCount_FreezeQty_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InPhysicalCount_FreezeQty_proc';

