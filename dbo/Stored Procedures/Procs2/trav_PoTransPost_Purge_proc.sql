
CREATE PROCEDURE dbo.trav_PoTransPost_Purge_proc
AS
BEGIN TRY
	DECLARE @BatchId pBatchId, @MoveToNewBatch bit

	--Retrieve global values
	SELECT @BatchId = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'NewBatchId'
	SELECT @MoveToNewBatch = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'MoveToNewBatch'

	IF @MoveToNewBatch IS NULL
	BEGIN
		RAISERROR(90025,16,1)
	END

	
	DELETE dbo.tblPoTransReceiptLandedCost
	FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransLotRcpt r ON t.TransID = r.TransID 
		INNER JOIN dbo.tblPoTransReceiptLandedCost ON r.ReceiptID = dbo.tblPoTransReceiptLandedCost.ReceiptID 

	DELETE dbo.tblPoTransSer
	FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransSer 
	ON t.TransID = dbo.tblPoTransSer.TransID 

	DELETE dbo.tblPoTransInvc_Rcpt 
	FROM dbo.tblPoTransLotRcpt l INNER JOIN dbo.tblPoTransInvc_Rcpt ON l.ReceiptId = dbo.tblPoTransInvc_Rcpt.ReceiptId
	INNER JOIN #CompletedTransactions t ON t.TransId = l.TransId

	DELETE dbo.tblPoTransLotRcpt
	FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransLotRcpt 
	ON t.TransID = dbo.tblPoTransLotRcpt.TransID 

	DELETE dbo.tblPoTransReceipt 
	FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransReceipt 
	ON t.TransID = dbo.tblPoTransReceipt.TransID 

	DELETE dbo.tblPoTransInvoice 
	FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransInvoice 
	ON t.TransID = dbo.tblPoTransInvoice.TransID 

	DELETE dbo.tblPoTransInvoiceTot 
	FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransInvoiceTot 
	ON t.TransID = dbo.tblPoTransInvoiceTot.TransID 

	DELETE dbo.tblPoTransInvoiceTax
	FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransInvoiceTax 
	ON t.TransID = dbo.tblPoTransInvoiceTax.TransID 

	DELETE dbo.tblInQty 
	FROM dbo.tblInQty INNER JOIN dbo.tblPoTransDetail d ON dbo.tblInQty.SeqNum = d.QtySeqNum 
	INNER JOIN #CompletedTransactions t ON d.TransID = t.TransID
	WHERE	d.QtySeqNum > 0

	DELETE dbo.tblPoTransDetailLandedCost
	FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransDetail d ON t.TransID = d.TransID  
		INNER JOIN dbo.tblPoTransDetailLandedCost ON d.TransID = dbo.tblPoTransDetailLandedCost.TransID AND d.EntryNum = dbo.tblPoTransDetailLandedCost.EntryNum

	UPDATE dbo.tblApOpenInvoice SET [Status] =4
	FROM dbo.tblApOpenInvoice i 
	INNER JOIN dbo.tblPoTransDeposit d  ON i.[Counter]=d.InvoiceCounter  OR i.GroupID = d.InvoiceCounter	
	INNER JOIN #CompletedTransactions t ON  t.TransID = d.TransID 

	UPDATE dbo.tblApOpenInvoice SET [Status] =4
	FROM dbo.tblApOpenInvoice i 
	INNER JOIN dbo.tblPoTransDeposit d  ON i.[Counter]=d.InvoiceCounter  OR i.GroupID = d.InvoiceCounter
	LEFT JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransID
	WHERE h.TransId IS NULL
	
	UPDATE dbo.tblSmTransLink SET DestStatus = 1
	WHERE SeqNum IN (SELECT d.LinkSeqNum FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransDetail d ON t.TransID = d.TransID
			WHERE d.LinkSeqNum IS NOT NULL) 
		AND DestType = 2	
	
	DELETE dbo.tblPoTransDeposit
	FROM dbo.tblPoTransDeposit d	
	LEFT JOIN dbo.tblPoTransHeader h ON d.TransID = h.TransID
	WHERE h.TransId IS NULL

	DELETE dbo.tblPoTransDetail 
	FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransDetail 
	ON t.TransID = dbo.tblPoTransDetail.TransID 	

	DELETE dbo.tblPoTransHeader 
	FROM dbo.tblPoTransHeader
	INNER JOIN 	 #CompletedTransactions t 
	ON t.TransID = dbo.tblPoTransHeader.TransID 
	
	DELETE dbo.tblPoTransRequest
	FROM dbo.tblPoTransRequest h 
		INNER JOIN #PostTransList b ON h.TransID = b.TransID 		
	WHERE h.TransId NOT IN (SELECT TransId FROM dbo.tblPoTransHeader) 

	DELETE dbo.tblPoTransInvoiceTax
	FROM #PostTransList t INNER JOIN dbo.tblPoTransInvoiceTax 
	ON t.TransID = dbo.tblPoTransInvoiceTax.TransID 

	DELETE dbo.tblPoTransDeposit
	FROM #CompletedTransactions t INNER JOIN dbo.tblPoTransDeposit
	ON t.TransID = dbo.tblPoTransDeposit.TransID 

	IF @MoveToNewBatch = 1 
		UPDATE dbo.tblPoTransHeader SET BatchId = @BatchID 
		FROM dbo.tblPoTransHeader INNER JOIN #PostTransList b 
			ON dbo.tblPoTransHeader.TransID = b.TransID 
	
	
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_Purge_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_Purge_proc';

