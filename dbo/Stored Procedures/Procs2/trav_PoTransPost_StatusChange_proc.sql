
CREATE PROCEDURE dbo.trav_PoTransPost_StatusChange_proc
AS
BEGIN TRY

	-- FLAG RECORDS AS POSTED (tblPoTransReceipt/tblPoTransInvoice)

	UPDATE dbo.tblPoTransLotRcpt SET Status = 1 
	FROM dbo.tblPoTransLotRcpt INNER JOIN #PostTransList i ON dbo.tblPoTransLotRcpt.TransID = i.TransID 
	WHERE dbo.tblPoTransLotRcpt.Status = 0

	UPDATE dbo.tblPoTransSer SET RcptStatus = 1 
	FROM dbo.tblPoTransSer INNER JOIN #PostTransList i ON dbo.tblPoTransSer.TransId = i.TransID 
	WHERE dbo.tblPoTransSer.RcptStatus = 0

	UPDATE dbo.tblPoTransInvoice SET Status = 1 
	FROM dbo.tblPoTransInvoice INNER JOIN #PostTransList i ON dbo.tblPoTransInvoice.TransID = i.TransID 
	WHERE dbo.tblPoTransInvoice.Status = 0

	UPDATE dbo.tblPoTransSer SET InvcStatus = 1 
	FROM dbo.tblPoTransSer INNER JOIN #PostTransList i ON dbo.tblPoTransSer.TransId = i.TransID 
	WHERE dbo.tblPoTransSer.InvcStatus = 0 AND dbo.tblPoTransSer.InvcNum IS NOT NULL

	-- Move current fields to posted (tblPoTransInvoiceTot), zero out current fields, and change Status to Posted
	UPDATE dbo.tblPoTransInvoiceTot SET PostTaxable = PostTaxable + CurrTaxable
		, PostNonTaxable = PostNonTaxable + CurrNonTaxable, PostSalesTax = PostSalesTax + CurrSalesTax
		, PostFreight = PostFreight + CurrFreight, PostMisc = PostMisc + CurrMisc
		, PostDisc = PostDisc + CurrDisc, PostPrepaid = PostPrepaid + CurrPrepaid
		, PostTaxableFgn = PostTaxableFgn + CurrTaxableFgn
		, PostNonTaxableFgn = PostNonTaxableFgn + CurrNonTaxableFgn
		, PostSalesTaxFgn = PostSalesTaxFgn + CurrSalesTaxFgn
		, PostFreightFgn = PostFreightFgn + CurrFreightFgn
		, PostMiscFgn = PostMiscFgn + CurrMiscFgn, PostDiscFgn = PostDiscFgn + CurrDiscFgn
		, PostPrepaidFgn = PostPrepaidFgn + CurrPrepaidFgn, CurrTaxable = 0, CurrNonTaxable = 0, CurrSalesTax = 0
		, CurrFreight = 0, CurrMisc = 0, CurrDisc = 0, CurrPrepaid = 0
		, CurrTaxableFgn = 0, CurrNonTaxableFgn = 0, CurrSalesTaxFgn = 0
		, CurrFreightFgn = 0, CurrMiscFgn = 0, CurrDiscFgn = 0, CurrPrepaidFgn = 0
		, CurrCheckNo = NULL, CurrCheckDate = NULL, CurrDueDate1 = NULL, CurrDueDate2 = NULL, CurrDueDate3 = NULL
		, CurrPmtAmt1 = 0, CurrPmtAmt2 = 0, CurrPmtAmt3 = 0
		, CurrPmtAmt1Fgn = 0, CurrPmtAmt2Fgn = 0, CurrPmtAmt3Fgn = 0
		, CurrTaxAdjAmt = 0, CurrTaxAdjAmtFgn = 0 
	FROM #PostTransList i INNER JOIN tblPoTransInvoiceTot ON i.TransID = dbo.tblPoTransInvoiceTot.TransId 
	WHERE CurrTaxablefgn != 0 OR CurrNonTaxablefgn != 0 OR CurrSalesTaxfgn != 0 OR  CurrFreightfgn != 0 OR  CurrMiscfgn != 0 OR  CurrTaxAdjAmtfgn != 0 OR CurrPrepaidFgn <> 0

	-- FLAG DETAIL LINES AS COMPLETED (tblPoTransDetail)
	UPDATE dbo.tblPoTransDetail SET LineStatus = 1 
	FROM (#PostTransList i INNER JOIN dbo.tblPoTransDetail ON i.TransID = dbo.tblPoTransDetail.TransID) 
		INNER JOIN (SELECT r.TransID, r.EntryNum, SUM(r.QtyFilled) RcptQty FROM #PostTransList i 
			INNER JOIN dbo.tblPoTransLotRcpt r ON i.TransID = r.TransID GROUP BY r.TransID, r.EntryNum) t 
			ON dbo.tblPoTransDetail.TransID = t.TransID AND dbo.tblPoTransDetail.EntryNum = t.EntryNum  
		INNER JOIN (SELECT v.TransID, v.EntryNum, SUM(v.Qty) InvcQty FROM #PostTransList i 
			INNER JOIN dbo.tblPoTransInvoice v ON i.TransID = v.TransID GROUP BY v.TransID, v.EntryNum) v 
			ON dbo.tblPoTransDetail.TransID = v.TransID  AND dbo.tblPoTransDetail.EntryNum = v.EntryNum
	WHERE dbo.tblPoTransDetail.LineStatus = 0 AND t.RcptQty >= QtyOrd AND v.InvcQty = RcptQty

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_StatusChange_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_StatusChange_proc';

