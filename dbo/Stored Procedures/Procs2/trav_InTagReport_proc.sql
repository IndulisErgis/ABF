
CREATE PROCEDURE [dbo].[trav_InTagReport_proc]
@BatchID  pBatchID = 'abc',
@Select  tinyint = 2, --0, Nonserilized Only; 1, Serialized Only; 2, Both;
@SortBy  nvarchar(150) = 'LocId, ItemId',
@StartTagNum  Int = 1,
@LastGoodTagNum  Int = NULL,
@DefaultNoBin bit = 0

AS
SET NOCOUNT ON
BEGIN TRY

DECLARE @SQL  NVarchar(1000)

CREATE TABLE #tmpInPhysCount (
	[SeqNum] Int NOT NULL ,
	[DtlSeqNum] Int NOT NULL,
	[ItemId] [pItemID] NULL ,
	[LocId] [pLocID] NULL ,
	[LotNum] [pLotNum] NULL ,
	[SerNum] [pSerNum] NULL ,
	[BinNum] [nvarchar] (10) NULL ,
	[ExtLocBId] [nvarchar] (10) NULL,
	[QtyFrozen] [pDecimal] NULL,
	[TagNum] [int] NULL,
	[DfltUom] [pUom] NULL ,
	[Descr] nvarchar(35) NULL,
	[ProductLine] [nvarchar] (12) NULL,
	CONSTRAINT [PK_tmpInPhysCount] PRIMARY KEY CLUSTERED (SeqNum,DtlSeqNum) 
)

CREATE TABLE #tmpInTag 
(
	[SeqNum] int NOT NULL, 
	[DtlSeqNum] int NOT NULL, 
	[TagNum] int NOT NULL IDENTITY(1,1),
	CONSTRAINT [PK_tmpInTag] PRIMARY KEY CLUSTERED (SeqNum,DtlSeqNum)
)

INSERT INTO #tmpInPhysCount ([SeqNum],[DtlSeqNum],[ItemId],[LocId],[LotNum],[QtyFrozen],[TagNum],[DfltUom],[Descr],[ProductLine],BinNum)
SELECT c.SeqNum,0,c.ItemId,c.LocId,c.LotNum,c.QtyFrozen/u.ConvFactor,c.TagNum,c.CountedUom,i.Descr,c.ProductLine,
CASE WHEN @DefaultNoBin = 1 AND (@Select = 2 OR @Select = 0) AND i.ItemType = 1 THEN c.DfltBinNum ELSE NULL END AS ExtLocAId
FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId 
	INNER JOIN dbo.tblInItemUom u ON c.ItemId = u.ItemId AND c.CountedUom = u.Uom
WHERE c.BatchId = @BatchID AND ((@Select = 0 OR @Select = 2) AND i.ItemType = 1)
AND (@LastGoodTagNum IS NULL OR c.TagNum > @LastGoodTagNum)

INSERT INTO #tmpInPhysCount ([SeqNum],[DtlSeqNum],[ItemId],[LocId],[LotNum],[QtyFrozen],[TagNum],[DfltUom],[Descr],[ProductLine],[SerNum]
,[BinNum]
,[ExtLocBID])
SELECT c.SeqNum,d.DtlSeqNum,c.ItemId,c.LocId,c.LotNum,d.QtyFrozen/u.ConvFactor,d.TagNum,d.CountedUom,i.Descr,c.ProductLine,d.SerNum
, d.ExtLocAId AS ExtLocAId,d.ExtLocBId
FROM dbo.tblInPhysCount c INNER JOIN dbo.tblInItem i ON c.ItemId = i.ItemId 
	INNER JOIN dbo.tblInPhysCountDetail d ON c.SeqNum = d.SeqNum 
	INNER JOIN dbo.tblInItemUom u ON c.ItemId = u.ItemId AND d.CountedUom = u.Uom
WHERE c.BatchId = @BatchID AND (@Select = 2 OR (@Select = 0 AND i.ItemType = 1) OR (@Select = 1 AND i.ItemType = 2))
AND (@LastGoodTagNum IS NULL OR d.TagNum > @LastGoodTagNum)

SET @SQL = N'INSERT INTO #tmpInTag (SeqNum,DtlSeqNum) SELECT c.SeqNum,c.DtlSeqNum FROM #tmpInPhysCount c ORDER BY ' + @SortBy
EXEC sp_executesql  @SQL

UPDATE #tmpInPhysCount SET TagNum = t.TagNum + @StartTagNum - 1 
FROM #tmpInPhysCount INNER JOIN #tmpInTag t ON #tmpInPhysCount.SeqNum = t.SeqNum AND #tmpInPhysCount.DtlSeqNum = t.DtlSeqNum

UPDATE dbo.tblInPhysCount SET TagNum = t.TagNum 
FROM dbo.tblInPhysCount INNER JOIN #tmpInPhysCount t ON dbo.tblInPhysCount.SeqNum = t.SeqNum
WHERE t.DtlSeqNum = 0

UPDATE dbo.tblInPhysCountDetail SET TagNum = t.TagNum 
FROM dbo.tblInPhysCountDetail INNER JOIN #tmpInPhysCount t ON dbo.tblInPhysCountDetail.SeqNum = t.SeqNum AND dbo.tblInPhysCountDetail.DtlSeqNum = t.DtlSeqNum
WHERE t.DtlSeqNum > 0

SELECT * FROM #tmpInPhysCount ORDER BY TagNum

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTagReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_InTagReport_proc';

