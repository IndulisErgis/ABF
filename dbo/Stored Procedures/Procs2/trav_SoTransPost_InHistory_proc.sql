
CREATE PROCEDURE dbo.trav_SoTransPost_InHistory_proc
AS
BEGIN TRY
	--PET:http://webfront:801/view.php?id=236036
	--PET:http://webfront:801/view.php?id=236509
	--PET:http://webfront:801/view.php?id=236978
	--PET:http://webfront:801/view.php?id=236845
	--PET:http://webfront:801/view.php?id=242886
	DECLARE @ReturnDirectToStock bit
	DECLARE @PrecCurr smallint

	SELECT @ReturnDirectToStock = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ReturnDirectToStock'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @ReturnDirectToStock IS NULL OR @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END
	
	--Update location last info
	UPDATE dbo.tblInItemLoc SET DateLastSale = h.InvcDate
	FROM dbo.tblInItemLoc INNER JOIN dbo.tblSoTransDetail d ON dbo.tblInItemLoc.ItemId = d.ItemId AND dbo.tblInItemLoc.LocId = d.LocId 
		INNER JOIN dbo.tblSoTransHeader h ON d.TransID = h.TransId INNER JOIN #PostTransList l ON h.TransId = l.TransId 
	WHERE d.[Status] = 0 AND d.QtyShipSell <> 0  --open line items with shipped quantities 
		AND (h.TransType > 0 AND (DateLastSale IS NULL OR h.InvcDate > DateLastSale))

	IF @ReturnDirectToStock = 1
	BEGIN
		UPDATE dbo.tblInItemLoc SET DateLastSaleRet = h.InvcDate
		FROM dbo.tblInItemLoc INNER JOIN dbo.tblSoTransDetail d ON dbo.tblInItemLoc.ItemId = d.ItemId AND dbo.tblInItemLoc.LocId = d.LocId 
			INNER JOIN dbo.tblSoTransHeader h ON d.TransID = h.TransId INNER JOIN #PostTransList l ON h.TransId = l.TransId 
		WHERE d.[Status] = 0 AND d.QtyShipSell <> 0  --open line items with shipped quantities 
			AND (h.TransType < 0 AND (DateLastSaleRet IS NULL OR h.InvcDate > DateLastSaleRet))
	END
	
	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId, RefId)
	SELECT d.HistSeqNum, h.FiscalYear, h.GLPeriod, h.InvcDate, h.BatchId, l.DefaultInvoiceNumber
	FROM dbo.tblSoTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId 
	INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransId
	WHERE d.[Status] = 0 AND d.HistSeqNum > 0  --open line items

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId, RefId, PriceUnit, PriceExt)
	SELECT e.HistSeqNum, h.FiscalYear, h.GLPeriod, h.InvcDate, h.BatchId, l.DefaultInvoiceNumber, d.UnitPriceSell, ROUND(d.UnitPriceSell * e.QtyFilled, @PrecCurr)
	FROM dbo.tblSoTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId 
	INNER JOIN dbo.tblSoTransDetail d ON h.TransId = d.TransId
	INNER JOIN dbo.tblSoTransDetailExt e ON d.TransId = e.TransId and d.EntryNum = e.EntryNum
	WHERE d.LottedYN = 1 AND e.LotNum IS NOT NULL AND e.QtyFilled <> 0 AND d.[Status] = 0 AND e.HistSeqNum > 0 --open line items, lotted

	EXEC dbo.trav_InUpdateHistory_proc

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_InHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SoTransPost_InHistory_proc';

