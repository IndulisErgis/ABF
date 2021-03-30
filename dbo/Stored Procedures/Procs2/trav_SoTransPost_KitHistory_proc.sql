
CREATE PROCEDURE dbo.trav_SoTransPost_KitHistory_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @MaxSeq int

	CREATE TABLE #tmpKitHistSum
	(
		HistSeqNum int NOT NULL Identity (1,1), 
		ItemId pItemId NOT NULL, 
		LocId pLocId NOT NULL, 
		SumYear smallint NOT NULL, 
		SumPeriod smallint NOT NULL, 
		GLPeriod smallint NOT NULL, 
		BatchId pBatchId NULL, 
		TransId pTransId NULL, 
		EntryNum int NOT NULL, 
		Uom pUOM NOT NULL, 
		ConvFactor pDecimal NOT NULL, 
		Qty pDecimal NULL, 
		Cost pDecimal NULL, 
		Price pDecimal NULL, 
		CustId pCustId NULL, 
		TransDate datetime NULL, 
		InvcNum pInvoiceNum NULL
	)


	--capture a list of kitted items being posted
	INSERT INTO #tmpKitHistSum (TransID, BatchID, GlPeriod, SumYear, SumPeriod, CustID, TransDate
		, InvcNum, EntryNum, ItemID, LocID, Uom, ConvFactor, Qty, Cost, Price) 
	SELECT p.TransId, p.BatchId, p.GLPeriod, p.FiscalYear, p.SumHistPeriod, p.SoldToId, p.TransDate
		, l.DefaultInvoiceNumber, d.EntryNum, d.ItemId, d.LocId
		, d.UnitsSell, d.ConversionFactor, d.QtyShipSell, d.UnitCostSell, d.UnitPriceSell 
	FROM dbo.tblSoTransHeader p 
	INNER JOIN dbo.tblSoTransDetail d ON p.TransId = d.TransID 
	INNER JOIN #PostTransList l on p.TransId = l.TransId
	WHERE d.Kit = 1 AND d.QtyShipSell > 0 AND d.[Status] = 0

	SELECT @MaxSeq = MAX(HistSeqNum) FROM dbo.tblBmKitHistSumm
	SET @MaxSeq = COALESCE(@MaxSeq, 0)

	--append the entries to the kit summary history
	INSERT INTO dbo.tblBmKitHistSumm (HistSeqNum, TransID, BatchID, GlPeriod, SumYear, SumPeriod, CustID, TransDate
		, InvcNum, ItemID, LocID, Uom, ConvFactor, Qty, Cost, Price, SrceID) 
	SELECT HistSeqNum + @MaxSeq, TransID, BatchID, GlPeriod, SumYear, SumPeriod, CustID, TransDate
		, InvcNum, ItemID, LocID, Uom, ConvFactor, Qty, Cost, Price, 'SO' 
	FROM #tmpKitHistSum

	-- add components
	INSERT INTO dbo.tblBmKitHistDetail (ItemId, LocId, ItemType, LottedYN, Qty
		, Uom, ConvFactor, UnitCost, UnitPrice, HistSeqNum, EntryNum) 
	SELECT d.ItemId, d.LocId, d.ItemType, d.LottedYN
		, CASE WHEN d.KitQty <> 0 AND t.ConvFactor <> 0 THEN (d.QtyShipSell / (d.KitQty * t.ConvFactor)) ELSE d.QtyShipSell END
		, d.UnitsSell, d.ConversionFactor, UnitCostSell, UnitPriceSell, t.HistSeqNum + @MaxSeq , d.EntryNum 
	FROM #tmpKitHistSum t 
	INNER JOIN dbo.tblSoTransDetail d ON t.TransID = d.TransID AND t.EntryNum = d.GrpId 

	-- add ser components
	INSERT INTO dbo.tblBmKitHistSer (HistSeqNum, EntryNumber, ItemId, LocId
		, LotNum, SerNum, CostUnit, PriceUnit) 
	SELECT t.HistSeqNum + @MaxSeq, dbo.tblSoTransSer.EntryNum, dbo.tblSoTransSer.ItemId, dbo.tblSoTransSer.LocId
		, dbo.tblSoTransSer.LotNum, dbo.tblSoTransSer.SerNum, dbo.tblSoTransSer.CostUnit, dbo.tblSoTransSer.PriceUnit 
	FROM #tmpKitHistSum t 
	INNER JOIN dbo.tblSoTransDetail d ON t.TransID = d.TransID AND t.EntryNum = d.GrpId 
	INNER JOIN dbo.tblSoTransSer ON d.EntryNum = dbo.tblSoTransSer.EntryNum AND d.TransID = dbo.tblSoTransSer.TransId 
 
	-- add lot components
	INSERT INTO dbo.tblBmKitHistLot (HistSeqNum, EntryNum, ItemId, LocId
		, LotNum, QtyTrans, CostUnit) 
	SELECT t.HistSeqNum + @MaxSeq, e.EntryNum, d.ItemId, d.LocId
		, e.LotNum, e.QtyFilled, e.CostUnit 
	FROM #tmpKitHistSum t 
	INNER JOIN dbo.tblSoTransDetail d ON t.TransID = d.TransID AND t.EntryNum = d.GrpId 
	INNER JOIN dbo.tblSoTransDetailExt e ON d.TransID = e.TransId AND d.EntryNum = e.EntryNum 
	WHERE d.LottedYn = 1 AND e.QtyFilled <> 0


END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_KitHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_KitHistory_proc';

