
CREATE PROCEDURE dbo.trav_PoTransPost_InvoiceHistory_proc
AS
BEGIN TRY
DECLARE @PrecCurr smallint, @CompId nvarchar(3),@InHsVendor nvarchar(10),@PoJcYn bit,@PostRun nvarchar(14)

--Retrieve global values
SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'
SELECT @CompId = Cast([Value] AS nvarchar(3)) FROM #GlobalValues WHERE [Key] = 'CompId'
SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
SELECT @PoJcYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'PoJcYn'
SELECT @InHsVendor = Cast([Value] AS nvarchar(10)) FROM #GlobalValues WHERE [Key] = 'InHsVendor'

IF @PrecCurr IS NULL OR @CompId IS NULL OR @PostRun IS NULL 
	OR @PoJcYn IS NULL
BEGIN
	RAISERROR(90025,16,1)
END
SET @InHsVendor = ISNULL(@InHsVendor,'')

SELECT T .TransId, T .InvcNum
	, MIN(CASE WHEN taxlevel = 1 THEN l.taxlocid ELSE NULL END) taxloc1
	, SUM(CONVERT(Decimal(28,10), CASE WHEN taxlevel = 1 THEN T.CurrTaxAmt ELSE 0 END)) taxamt1
	, SUM(CONVERT(Decimal(28,10), CASE WHEN taxlevel = 1 THEN T.CurrTaxAmtFgn ELSE 0 END)) taxamt1fgn
	, MIN(CASE WHEN taxlevel = 2 THEN l.taxlocid ELSE NULL END) taxloc2
	, SUM(CONVERT(Decimal(28,10), CASE WHEN taxlevel = 2 THEN T.CurrTaxAmt ELSE 0 END)) taxamt2
	, SUM(CONVERT(Decimal(28,10), CASE WHEN taxlevel = 2 THEN T.CurrTaxAmtFgn ELSE 0 END)) taxamt2Fgn
	, MIN(CASE WHEN taxlevel = 3 THEN l.taxlocid ELSE NULL END) taxloc3
	, SUM(CONVERT(Decimal(28,10), CASE WHEN taxlevel = 3 THEN T.CurrTaxAmt ELSE 0 END)) taxamt3
	, SUM(CONVERT(Decimal(28,10), CASE WHEN taxlevel = 3 THEN T.CurrTaxAmtFgn ELSE 0 END)) taxamt3Fgn
	, MIN(CASE WHEN taxlevel = 4 THEN l.taxlocid ELSE NULL END) taxloc4
	, SUM(CONVERT(Decimal(28,10), CASE WHEN taxlevel = 4 THEN T.CurrTaxAmt ELSE 0 END)) taxamt4
	, SUM(CONVERT(Decimal(28,10), CASE WHEN taxlevel = 4 THEN T.CurrTaxAmtFgn ELSE 0 END)) taxamt4Fgn
	, MIN(CASE WHEN taxlevel = 5 THEN l.taxlocid ELSE NULL END) taxloc5
	, SUM(CONVERT(Decimal(28,10), CASE WHEN taxlevel = 5 THEN T.CurrTaxAmt ELSE 0 END)) taxamt5
	, SUM(CONVERT(Decimal(28,10), CASE WHEN taxlevel = 5 THEN T.CurrTaxAmtFgn ELSE 0 END)) taxamt5Fgn 
INTO #tmpTaxCross 
FROM #PostTransList s INNER JOIN dbo.tblPoTransHeader h ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransInvoiceTot v ON h.TransID = v.TransId 
	INNER JOIN dbo.tblPoTransInvoiceTax t ON v.TransId = t.TransId AND v.InvcNum = t.InvcNum 
	INNER JOIN dbo.tblSmTaxLoc l ON t.TaxLocID = l.TaxLocId 
	LEFT JOIN (SELECT TransID, InvoiceNum FROM dbo.tblPoTransInvoice WHERE [Status] = 0 GROUP BY TransID, InvoiceNum) i
		 ON t.TransId = i.TransID AND t.InvcNum = i.InvoiceNum 
WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND (v.CurrSalesTaxfgn != 0 OR  v.CurrFreightfgn != 0 OR  v.CurrMiscfgn != 0 OR  v.CurrTaxAdjAmtfgn <> 0 OR v.CurrPrepaidFgn <> 0 OR i.TransID IS NOT NULL)
GROUP BY T .transid, T .Invcnum

UPDATE #tmpTaxCross SET taxamt1 = ROUND(taxamt1, @PrecCurr)
	, taxamt2 = ROUND(taxamt2, @PrecCurr)
	, taxamt3 = ROUND(taxamt3, @PrecCurr)
	, taxamt4 = ROUND(taxamt4, @PrecCurr)
	, taxamt5 = ROUND(taxamt5, @PrecCurr)
	, taxamt1fgn = ROUND(taxamt1fgn, @PrecCurr)
	, taxamt2fgn = ROUND(taxamt2fgn, @PrecCurr)
	, taxamt3fgn = ROUND(taxamt3fgn, @PrecCurr)
	, taxamt4fgn = ROUND(taxamt4fgn, @PrecCurr)
	, taxamt5fgn = ROUND(taxamt5fgn, @PrecCurr)
 
-- DETAIL HISTORY RECORDS (tblApHistHeader / tblApHistDetail)
INSERT INTO dbo.tblApHistHeader (PostRun, TransId, InvoiceNum, WhseId, VendorID, CurrencyId, ExchRate, PmtCurrencyId, PmtExchRate
	, PONum, TaxGrpID, TaxableYn, DistCode, TermsCode, Notes, InvoiceDate, TransType, Subtotal
	, Taxable, Taxablefgn, NonTaxable,  NonTaxablefgn, SalesTax, Freight, Misc, CashDisc, PrepaidAmt
	, SubtotalFgn, SalesTaxFgn, FreightFgn, MiscFgn, CashDiscFgn, PrepaidAmtFgn, CheckNum, CheckDate
	, PmtAmt1, PmtAmt1Fgn, PmtAmt2, PmtAmt2Fgn, PmtAmt3, PmtAmt3Fgn
	, DueDate1, DueDate2, DueDate3, TaxClassFreight, TaxClassMisc, TaxAdjClass, TaxAdjLocID, TaxAdjAmt, TaxAdjAmtFgn
	, GLPeriod, FiscalYear, Ten99InvoiceYN, Source, TaxLocID1, TaxAmt1, TaxAmt1Fgn
	, TaxLocID2, TaxAmt2, TaxAmt2Fgn, TaxLocID3, TaxAmt3, TaxAmt3Fgn, TaxLocID4, TaxAmt4, TaxAmt4Fgn
	, TaxLocID5, TaxAmt5, TaxAmt5Fgn, SumHistPeriod,GLAcctAP,GLAcctFreight,GLAcctTaxAdj,GLAcctMisc, DiscDueDate, CF, BatchId
	, ChkFiscalYear, ChkGlPeriod, BankID) 
SELECT @PostRun, t.TransId, t.InvcNum, h.LocId, h.VendorId, h.CurrencyID, t.InvoiceExchRate, t.PmtCurrencyId, t.PmtExchRate
	, h.TransId, h.TaxGrpID, h.TaxableYn, h.DistCode, h.TermsCode, h.Notes, t.InvcDate, SIGN(TransType)
	, CurrTaxable + CurrNonTaxable, t.CurrTaxable, t.CurrTaxablefgn, t.CurrNonTaxable,  t.CurrNonTaxablefgn
	, CurrSalesTax, t.CurrFreight, t.CurrMisc, t.CurrDisc, t.CurrPrepaid, CurrTaxableFgn + CurrNonTaxableFgn
	, CurrSalesTaxFgn, t.CurrFreightFgn, t.CurrMiscFgn, t.CurrDiscFgn, t.CurrPrepaidFgn
	, t.CurrCheckNo, t.CurrCheckDate, t.CurrPmtAmt1, t.CurrPmtAmt1Fgn, t.CurrPmtAmt2, t.CurrPmtAmt2Fgn
	, t.CurrPmtAmt3, t.CurrPmtAmt3Fgn, t.CurrDueDate1, t.CurrDueDate2, t.CurrDueDate3
	, t.CurrTaxClassFreight, t.CurrTaxClassMisc, t.CurrTaxAdjClass, t.CurrTaxAdjLocID, t.CurrTaxAdjAmt, t.CurrTaxAdjAmtFgn
	, t.GLPeriod, t.FiscalYear, t.Ten99InvoiceYN, 1, x.taxloc1, x.taxamt1, x.taxamt1fgn
	, x.taxloc2, x.taxamt2, x.taxamt2fgn, x.taxloc3, x.taxamt3, x.taxamt3fgn
	, x.taxloc4, x.taxamt4, x.taxamt4fgn, x.taxloc5, x.taxamt5, x.taxamt5fgn,t.GLPeriod
	,c.PayablesGLAcct, c.FreightGLAcct, td.ExpenseAcct , c.MiscGLAcct,t.DiscDueDate, h.CF, h.BatchId
	, t.CurrChkFiscalYear, t.CurrChkGlPeriod, t.CurrBankID
FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList s ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId 
	INNER JOIN #tmpTaxCross x ON t.TransID = x.TransID AND t.InvcNum = x.InvcNum
	INNER JOIN dbo.tblApDistCode c ON h.DistCode = c.DistCode 
	LEFT JOIN dbo.tblSmTaxLocDetail td ON t.CurrTaxAdjLocID=td.TaxLocID AND t.CurrTaxAdjClass=td.TaxClassCode 
	LEFT JOIN (SELECT TransID, InvoiceNum FROM dbo.tblPoTransInvoice WHERE [Status] = 0 GROUP BY TransID, InvoiceNum) i 
		ON t.TransId = i.TransID AND t.InvcNum = i.InvoiceNum
WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND (t.CurrSalesTaxfgn != 0 OR  t.CurrFreightfgn != 0 OR  t.CurrMiscfgn != 0 OR  t.CurrTaxAdjAmtfgn != 0 OR t.CurrPrepaidFgn <> 0 OR i.TransID IS NOT NULL)

--Sales Tax (-1)
INSERT INTO dbo.tblApHistDetail (PostRun, TransID, InvoiceNum
	, EntryNum, LineSeq, WhseId, PartType, TaxClass
	, ConversionFactor, Qty, QtyBase, UnitCost, ExtCost, UnitCostFgn, ExtCostFgn)
SELECT @PostRun, t.TransId, t.InvcNum
	, -1, 0, LocId, 0, 0
	, 1, 1, 1, CurrSalesTax + CurrTaxAdjAmt, CurrSalesTax + CurrTaxAdjAmt
	, CurrSalesTaxFgn + CurrTaxAdjAmtFgn, CurrSalesTaxFgn + CurrTaxAdjAmtFgn
FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList s ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId 
	INNER JOIN dbo.tblApDistCode c ON h.DistCode = c.DistCode 
WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND ((CurrSalesTax + CurrTaxAdjAmt) <> 0 OR (CurrSalesTaxFgn + CurrTaxAdjAmtFgn) <> 0)

--Freight (-2)
INSERT INTO dbo.tblApHistDetail (PostRun, TransID, InvoiceNum
	, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcct
	, ConversionFactor, Qty, QtyBase, UnitCost, ExtCost, UnitCostFgn, ExtCostFgn)
SELECT @PostRun, t.TransId, t.InvcNum
	, -2, 0, LocId, 0, CurrTaxClassFreight, c.FreightGLAcct
	, 1, 1, 1, CurrFreight, CurrFreight, CurrFreightFgn, CurrFreightFgn
FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList s ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId 
	INNER JOIN dbo.tblApDistCode c ON h.DistCode = c.DistCode 
WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND (CurrFreight <> 0 OR CurrFreightFgn <> 0)

--Misc (-3)
INSERT INTO dbo.tblApHistDetail (PostRun, TransID, InvoiceNum
	, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcct
	, ConversionFactor, Qty, QtyBase, UnitCost, ExtCost, UnitCostFgn, ExtCostFgn)
SELECT @PostRun, t.TransId, t.InvcNum
	, -3, 0, LocId, 0, CurrTaxClassMisc, c.MiscGLAcct
	, 1, 1, 1, CurrMisc, CurrMisc, CurrMiscFgn, CurrMiscFgn
FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList s ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId 
	INNER JOIN dbo.tblApDistCode c ON h.DistCode = c.DistCode 
WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND (CurrMisc <> 0 OR CurrMiscFgn <> 0)


INSERT INTO dbo.tblApHistDetail (PostRun, TransID, InvoiceNum, EntryNum, HistSeqNum, PartID, PartType, [Desc], GLAcct
	, Qty, QtyBase, Units, UnitsBase, UnitCost, ExtCost, UnitCostFgn, ExtCostFgn, GLDesc, AddnlDesc
	, WhseID, ConversionFactor, BinNum, TaxClass, LottedYN, InItemYN, TransHistId, CustomerID
	, JobId, ProjName, PhaseId, PhaseName, TaskId, TaskName, UnitInc, ExtInc, ProjItemYn, GLAcctSales, GLAcctWIP, CF) 
SELECT @PostRun, v.TransID, v.InvoiceNum, v.EntryNum, v.HistSeqNum, d.ItemId, d.ItemType, d.Descr, d.GLAcct
	, v.Qty, v.Qty * ConversionFactor, d.Units, d.UnitsBase, v.UnitCost, v.ExtCost, v.UnitCostFgn, v.ExtCostFgn, d.GLDesc, d.AddnlDescr
	, d.LocId, d.ConversionFactor, d.BinNum, d.TaxClass, d.LottedYN, d.InItemYN, v.TransHistID, d.CustID
	,j.ProjectName, j.[Description], dd.PhaseId, ss.[Description], dd.TaskId, sc.[Description],
    d.UnitInc, d.ExtInc, d.ProjItemYn, d.GLAcctSales, d.GLAcctWIP, d.CF 
FROM dbo.tblPoTransHeader h 
    INNER JOIN #PostTransList s ON s.TransId = h.TransID
	INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
	INNER JOIN dbo.tblPoTransInvoice v ON d.EntryNum = v.EntryNum AND d.TransID = v.TransID 
	LEFT JOIN dbo.tblPcProjectDetail dd ON d.ProjectDetailId = dd.Id 
	LEFT JOIN dbo.trav_PcProject_view j ON dd.ProjectId = j.Id
	LEFT JOIN dbo.tblPcPhase ss ON dd.PhaseId = ss.PhaseId
	Left Join dbo.tblPcTask sc ON dd.TaskID = sc.TaskID
	LEFT JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id 
	WHERE (h.VendorId <> @InHsVendor) AND v.Status = 0

--FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList s ON s .TransId = h.TransID
	--INNER JOIN dbo.tblPoTransDetail d ON h.TransId = d.TransID 
	--INNER JOIN dbo.tblPoTransInvoice v ON d.EntryNum = v.EntryNum AND d.TransID = v.TransID 
--WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND  v.Status = 0



-- insert PostRun into tblApHistRecur 
UPDATE dbo.tblApHistRecur SET PostRun = @PostRun 
FROM dbo.tblApHistRecur 
	INNER JOIN #PostTransList i ON dbo.tblApHistRecur.TransID = i.TransID 
WHERE dbo.tblApHistRecur.Source = 1 AND PostRun IS NULL

INSERT INTO dbo.tblApHistInvoiceTax (PostRun, TransId, InvcNum, TaxLocID, TaxClass, ExpAcct
	, TaxAmt, Refundable, Taxable, NonTaxable, TaxAmtFgn, RefundableFgn, TaxableFgn, NonTaxableFgn, CF) 
SELECT @PostRun, v.TransId, v.InvcNum, v.TaxLocID, v.TaxClass, v.ExpAcct, v.CurrTaxAmt, v.CurrRefundable
	, v.CurrTaxable, v.CurrNonTaxable, v.CurrTaxAmtFgn, v.CurrRefundableFgn, v.CurrTaxableFgn, v.CurrNonTaxableFgn, v.CF 
FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList i ON i .TransId = h.TransID
	 INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
	INNER JOIN dbo.tblPoTransInvoiceTax v ON t.InvcNum = v.InvcNum AND t.TransId = v.TransId 
	LEFT JOIN (SELECT TransID, InvoiceNum FROM dbo.tblPoTransInvoice WHERE [Status] = 0 GROUP BY TransID, InvoiceNum) c 
		ON t.TransId = c.TransID AND t.InvcNum = c.InvoiceNum
WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND (t.CurrSalesTaxfgn != 0 OR  t.CurrFreightfgn != 0 OR  t.CurrMiscfgn != 0 OR  t.CurrTaxAdjAmtfgn != 0 OR t.CurrPrepaidFgn <> 0 OR c.TransID IS NOT NULL)

--todo, SeqNum
INSERT INTO dbo.tblApHistLot (PostRun, TransId, InvoiceNum, EntryNum, SeqNum, LotNum
	, QtyFilled, CostUnit, CostUnitFgn, HistSeqNum, Cmnt, CF) 
SELECT @PostRun, v.TransId, v.InvoiceNum, v.EntryNum, LEFT(l.ReceiptId,15), l.LotNum
	, r.Qty, v.UnitCost, v.UnitCostFgn, v.HistSeqNum, l.LotCmnt, l.CF 
FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList s ON s .TransId = h.TransID 
	INNER JOIN	dbo.tblPoTransInvoice v ON h.TransID = v.TransId 
	INNER JOIN dbo.tblPoTransInvc_Rcpt r on v.InvoiceID = r.InvoiceID
	INNER JOIN dbo.tblPoTransLotRcpt l on l.ReceiptID = r.ReceiptID 
WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND v.Status = 0 AND l.LotNum IS NOT NULL

INSERT INTO dbo.tblApHistSer (PostRun, TransId, InvoiceNum, EntryNum, SeqNum
	, LotNum, SerNum, Cmnt, CostUnit, CostUnitFgn, HistSeqNum, CF) 
SELECT @PostRun, s.TransId, s.InvcNum, s.EntryNum, s.RcptNum
	, s.LotNum, s.SerNum, s.SerCmnt, s.InvcUnitCost, s.InvcUnitCostFgn, s.SerHistSeqNum, s.CF 
FROM dbo.tblPoTransHeader h INNER JOIN #PostTransList i ON i .TransId = h.TransID
	 INNER JOIN dbo.tblPoTransSer s ON h.TransID = s.TransId 
WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND s.InvcNum Is Not Null AND s.InvcStatus = 0 

-- update tblSmTaxLocTrans with tax amounts TaxLoc changes
INSERT dbo.tblSmTaxLocTrans (TaxLocId, TaxClassCode, PostRun, SourceCode
	, LinkID, LinkIDSub, LinkIDSubLine, TransDate, GLPeriod, FiscalYear, TaxSales, NonTaxSales
	, TaxCollect, TaxPurch, NonTaxPurch, TaxCalcPurch, TaxPaid, TaxRefund) 
SELECT x.TaxLocID, x.TaxClass, @PostRun, 'PO'
	, x.TransID,  NULL, NULL, h.TransDate, t.GLPeriod, t.FiscalYear, 0, 0, 0
	, SUM((CONVERT(Decimal(28,10), SIGN(h.TransType)) * CONVERT(Decimal(28,10), x.CurrTaxable)))
	, SUM((CONVERT(Decimal(28,10), SIGN(h.TransType)) * CONVERT(Decimal(28,10), x.CurrNonTaxable)))
	, SUM((CONVERT(Decimal(28,10), SIGN(h.TransType)) * CONVERT(Decimal(28,10), x.CurrTaxAmt)))
	, SUM((CONVERT(Decimal(28,10), SIGN(h.TransType)) * CONVERT(Decimal(28,10), x.CurrTaxAmt)))
	, SUM((CONVERT(Decimal(28,10), SIGN(h.TransType)) * CONVERT(Decimal(28,10), x.CurrRefundable))) 
FROM #PostTransList l INNER JOIN dbo.tblPoTransHeader h ON l.TransId = h.TransID
	INNER JOIN dbo.tblPoTransInvoiceTot t ON l.TransID = t.TransId 
	INNER JOIN dbo.tblPoTransInvoiceTax x ON t.TransId = x.TransId AND t.InvcNum = x.InvcNum
	LEFT JOIN (SELECT TransID, InvoiceNum FROM dbo.tblPoTransInvoice WHERE [Status] = 0 GROUP BY TransID, InvoiceNum) i
		 ON t.TransId = i.TransID AND t.InvcNum = i.InvoiceNum 
WHERE (@PoJcYn = 0 OR h.VendorId <> @InHsVendor) AND (t.CurrSalesTaxfgn != 0 OR  t.CurrFreightfgn != 0 OR  t.CurrMiscfgn != 0 OR  t.CurrTaxAdjAmtfgn <> 0 OR t.CurrPrepaidFgn <> 0 OR i.TransID IS NOT NULL)	
GROUP BY x.TransID, x.TaxLocID, x.TaxClass, h.TransDate, t.GLPeriod, t.FiscalYear

-- insert AdjAmount to TaxPaid
INSERT dbo.tblSmTaxLocTrans (TaxLocId, TaxClassCode, PostRun, SourceCode
	, LinkID, LinkIDSub, LinkIDSubLine, TransDate, GLPeriod, FiscalYear, TaxSales, NonTaxSales
	, TaxCollect, TaxPurch, NonTaxPurch, TaxCalcPurch, TaxPaid, TaxRefund) 
SELECT t.CurrTaxAdjLocID, t.CurrTaxAdjClass, @PostRun, 'PO'
	, h.TransID,  NULL, NULL, h.TransDate, t.GLPeriod, t.FiscalYear, 0, 0, 0, 0, 0, 0
	, SUM((CONVERT(Decimal(28,10), SIGN(h.TransType)) * CONVERT(Decimal(28,10), t.CurrTaxAdjAmt)))
	, 0 
FROM (#PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransID = h.TransId) 
	INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId 
WHERE  (@PoJcYn = 0 OR h.VendorID <> @InHsVendor) AND t.CurrTaxAdjAmt <> 0 
GROUP BY h.TransID, t.CurrTaxAdjLocID, t.CurrTaxAdjClass, h.TransDate, t.GLPeriod, t.FiscalYear

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_InvoiceHistory_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_InvoiceHistory_proc';

