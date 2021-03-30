
CREATE PROCEDURE dbo.trav_ArTransPost_InHistory_proc
AS
BEGIN TRY
	--PET:http://webfront:801/view.php?id=242886
	DECLARE @PrecCurr smallint

	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @PrecCurr IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId, RefId)
	SELECT d.HistSeqNum, h.FiscalYear, h.GLPeriod, h.InvcDate, h.BatchId, ISNULL(h.InvcNum, l.DefaultInvoiceNumber)
	FROM dbo.tblArTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId 
	INNER JOIN dbo.tblArTransDetail d ON h.TransId = d.TransId
	WHERE d.HistSeqNum > 0

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId, RefId, PriceUnit, PriceExt)
	SELECT e.HistSeqNum, h.FiscalYear, h.GLPeriod, h.InvcDate, h.BatchId, ISNULL(h.InvcNum, l.DefaultInvoiceNumber), d.UnitPriceSell, ROUND(d.UnitPriceSell * e.QtyFilled, @PrecCurr)
	FROM dbo.tblArTransHeader h 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId 
	INNER JOIN dbo.tblArTransDetail d ON h.TransId = d.TransID
	INNER JOIN dbo.tblArTransLot e ON d.TransId = e.TransId AND d.EntryNum = e.EntryNum
	WHERE e.HistSeqNum > 0

	EXEC dbo.trav_InUpdateHistory_proc

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_InHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArTransPost_InHistory_proc';

