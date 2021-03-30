
CREATE PROCEDURE [dbo].[trav_InLocationWorkSheetReport_proc]
@BatchID  pBatchID = 'abc',
@Select  tinyint = 2, --0, Nonserilized Only; 1, Serialized Only; 2, Both;
@PrintZeroQty bit = 1, -- Print Items with Zero Quantities.
@IncludeNullBin bit = 0, --Include null bins
@DefaultNoBin bit = 0
AS
SET NOCOUNT ON
BEGIN TRY

CREATE TABLE #tmpCountList
(
	SeqNum int NOT NULL 
	CONSTRAINT [PK_#tmpCountList] PRIMARY KEY CLUSTERED 
	(
		[SeqNum]
	)
)
INSERT INTO #tmpCountList (SeqNum)
SELECT c.SeqNum
FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId 
	LEFT JOIN (SELECT SeqNum, SUM(QtyFrozen) AS DetailQtyFrozen FROM dbo.tblInPhysCountDetail GROUP BY SeqNum) d ON c.SeqNum = d.SeqNum
WHERE c.BatchId = @BatchID AND (@Select = 2 OR (@Select = 0 AND i.ItemType = 1) OR (@Select = 1 AND i.ItemType = 2))
	AND (@PrintZeroQty = 1 OR c.QtyFrozen <> 0 OR ISNULL(d.DetailQtyFrozen,0) <> 0 )
	
SELECT c.BatchId, c.SeqNum, c.ItemId, c.LocId, c.LotNum, c.QtyFrozen/u.ConvFactor AS QtyFrozen, c.TagNum, c.CountedUom, i.Descr, c.ProductLine, i.ItemType, i.LottedYn, '' AS SortBy, 
	CASE WHEN @DefaultNoBin = 1 THEN c.DfltBinNum ELSE NULL END AS BinNum, NULL AS ExtLocBId
FROM #tmpCountList t INNER JOIN dbo.tblInPhysCount c ON t.SeqNum = c.SeqNum 
	INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId 
	INNER JOIN dbo.tblInItemUom u ON c.ItemId = u.ItemId AND c.CountedUom = u.Uom 
WHERE i.ItemType = 1 AND (@IncludeNullBin = 1 OR @DefaultNoBin = 1)
UNION ALL
SELECT c.BatchId, c.SeqNum, c.ItemId, c.LocId, c.LotNum, d.QtyFrozen/u.ConvFactor AS QtyFrozen, d.TagNum, d.CountedUom, i.Descr, c.ProductLine, i.ItemType, i.LottedYn, '' AS SortBy, d.ExtLocAId AS [BinNum], d.ExtLocBId
FROM #tmpCountList t INNER JOIN dbo.tblInPhysCount c ON t.SeqNum = c.SeqNum 
	INNER JOIN dbo.tblInPhysCountDetail d ON c.SeqNum = d.SeqNum
	INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId 
	INNER JOIN dbo.tblInItemUom u ON c.ItemId = u.ItemId AND d.CountedUom = u.Uom 
WHERE i.ItemType = 1
UNION ALL
SELECT c.BatchId, c.SeqNum, c.ItemId, c.LocId, c.LotNum, 0 AS QtyFrozen, 0 AS TagNum, NULL AS CountedUom, i.Descr, c.ProductLine, i.ItemType, i.LottedYn, '' AS SortBy
, d.ExtLocAId AS [BinNum]
, NULL AS ExtLocBId

FROM #tmpCountList t INNER JOIN dbo.tblInPhysCount c ON t.SeqNum = c.SeqNum 
	INNER JOIN dbo.tblInPhysCountDetail d ON c.SeqNum = d.SeqNum
	INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId 
	INNER JOIN dbo.tblInItemUom u ON c.ItemId = u.ItemId AND d.CountedUom = u.Uom 
WHERE i.ItemType = 2 AND (@IncludeNullBin = 1 OR d.ExtLocAId IS NOT NULL)
GROUP BY c.BatchId, c.SeqNum, c.ItemId, c.LocId, c.LotNum, i.Descr, c.ProductLine, i.ItemType, i.LottedYn, d.ExtLocAId

SELECT d.SeqNum, d.QtyFrozen, d.TagNum, d.CountedUom, d.SerNum, d.ExtLocAId AS [BinNum], d.ExtLocBId
FROM #tmpCountList t INNER JOIN dbo.tblInPhysCount c ON t.SeqNum = c.SeqNum
	INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId 
	INNER JOIN dbo.tblInPhysCountDetail d ON c.SeqNum = d.SeqNum 
WHERE i.ItemType = 2 AND (@IncludeNullBin = 1 OR d.ExtLocAId IS NOT NULL)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InLocationWorkSheetReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InLocationWorkSheetReport_proc';

