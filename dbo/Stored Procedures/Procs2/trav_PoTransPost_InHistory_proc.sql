
CREATE PROCEDURE dbo.trav_PoTransPost_InHistory_proc
AS
BEGIN TRY

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId)
	SELECT d.HistSeqNum, h.FiscalYear, h.GlPeriod, h.ReceiptDate, r.BatchId
	FROM dbo.tblPoTransReceipt h INNER JOIN #PostTransList l ON h.TransId = l.TransId 
		INNER JOIN dbo.tblPoTransLotRcpt d ON h.TransId = d.TransId AND h.ReceiptNum = d.RcptNum 
		INNER JOIN dbo.tblPoTransHeader r ON l.TransId = r.TransId
	WHERE d.HistSeqNum > 0

	INSERT INTO #InHistory (HistSeqNum, FiscalYear, FiscalPeriod, TransDate, BatchId)
	SELECT d.HistSeqNum, h.FiscalYear, h.GLPeriod, h.InvcDate, r.BatchId
	FROM dbo.tblPoTransInvoiceTot h INNER JOIN #PostTransList l ON h.TransId = l.TransId 
		INNER JOIN dbo.tblPoTransInvoice i ON h.TransId = i.TransId AND h.InvcNum = i.InvoiceNum
		INNER JOIN dbo.tblPoTransInvc_Rcpt d ON i.InvoiceId = d.InvoiceId
		INNER JOIN dbo.tblPoTransHeader r ON l.TransId = r.TransId
	WHERE d.HistSeqNum > 0

	EXEC dbo.trav_InUpdateHistory_proc

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_InHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_InHistory_proc';

