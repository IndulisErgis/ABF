
CREATE PROCEDURE dbo.trav_ApTransPost_History_proc
AS
BEGIN TRY
DECLARE @TransAllocYn bit, @PostRun nvarchar(14), @ApJcYn bit

--Retrieve global values
SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
SELECT @ApJcYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'ApJcYn'
SELECT @TransAllocYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'TransAllocYn'

IF @PostRun IS NULL OR @ApJcYn IS NULL OR @TransAllocYn IS NULL
BEGIN
	RAISERROR(90025,16,1)
END

-- update Detail history tables tblApHistHeader & tblApHistDetail
-- append header info to tblApHistHeader
INSERT dbo.tblApHistHeader (PostRun, TransID, BatchId, WhseId, VendorID, InvoiceNum, InvoiceDate, TransType, PONum
, DistCode, TermsCode, DueDate1, DueDate2, DueDate3, PmtAmt1, PmtAmt2, PmtAmt3
, Subtotal, SalesTax, Freight, Misc, CashDisc, PrepaidAmt, CurrencyId, ExchRate, PmtCurrencyId,  PmtExchRate
, PmtAmt1Fgn, PmtAmt2Fgn, PmtAmt3Fgn, SubtotalFgn, SalesTaxFgn, FreightFgn, MiscFgn, CashDiscFgn, PrepaidAmtFgn
, CheckNum, CheckDate, PostDate, GLPeriod, FiscalYear, Ten99InvoiceYN, Status, Notes, TaxGrpID, TaxableYn, Taxable, NonTaxable
, TaxableFgn, NonTaxableFgn, TaxClassFreight, TaxClassMisc, TaxLocID1, TaxAmt1, TaxAmt1Fgn, TaxLocID2, TaxAmt2, TaxAmt2Fgn
, TaxLocID3, TaxAmt3, TaxAmt3Fgn, TaxLocID4, TaxAmt4, TaxAmt4Fgn, TaxLocID5, TaxAmt5, TaxAmt5Fgn
, TaxAdjClass, TaxAdjLocID, TaxAdjAmt, TaxAdjAmtFgn,SumHistPeriod,GLAcctAP,GLAcctFreight,GLAcctTaxAdj,GLAcctMisc, DiscDueDate, CF
, ChkFiscalYear, ChkGlPeriod, BankID) 
SELECT @PostRun, t.TransID, t.BatchId, WhseId, VendorID, InvoiceNum, InvoiceDate, TransType, PONum
, t.DistCode, TermsCode, DueDate1, DueDate2, DueDate3, PmtAmt1, PmtAmt2, PmtAmt3
, Subtotal, SalesTax, Freight, Misc, CashDisc, PrepaidAmt, CurrencyId,  ExchRate,PmtCurrencyId, PmtExchRate
, PmtAmt1Fgn, PmtAmt2Fgn, PmtAmt3Fgn, SubtotalFgn, SalesTaxFgn, FreightFgn, MiscFgn, CashDiscFgn, PrepaidAmtFgn
, CheckNum, CheckDate, PostDate, t.GLPeriod, FiscalYear, Ten99InvoiceYN, Status, Notes, TaxGrpID, t.TaxableYn, Taxable, NonTaxable
, TaxableFgn, NonTaxableFgn, TaxClassFreight, TaxClassMisc, TaxLocID1, TaxAmt1, TaxAmt1Fgn, TaxLocID2, TaxAmt2, TaxAmt2Fgn
, TaxLocID3, TaxAmt3, TaxAmt3Fgn, TaxLocID4, TaxAmt4, TaxAmt4Fgn, TaxLocID5, TaxAmt5, TaxAmt5Fgn
, TaxAdjClass, TaxAdjLocID, TaxAdjAmt, TaxAdjAmtFgn ,t.GLPeriod, d.PayablesGLAcct, d.FreightGLAcct, x.ExpenseAcct , d.MiscGLAcct, t.DiscDueDate, t.CF
, t.ChkFiscalYear, t.ChkGlPeriod, t.BankID
FROM dbo.tblApTransHeader t INNER JOIN #PostTransList l ON t.TransId = l.TransId 
INNER JOIN dbo.tblApDistCode d ON t.DistCode = d.DistCode 
LEFT JOIN dbo.tblSmTaxLocDetail x ON t.TaxAdjClass = x.TaxClassCode
		AND t.TaxAdjLocID  =  x.TaxLocId

--Sales Tax (-1)
INSERT INTO dbo.tblApHistDetail (PostRun, TransID, InvoiceNum
	, EntryNum, LineSeq, WhseId, PartType, TaxClass
	, ConversionFactor, Qty, QtyBase, UnitCost, ExtCost, UnitCostFgn, ExtCostFgn)
SELECT @PostRun, t.TransId, InvoiceNum
	, -1, 0, WhseId, 0, 0
	, 1, 1, 1, SalesTax + TaxAdjAmt, SalesTax + TaxAdjAmt, SalesTaxFgn + TaxAdjAmtFgn, SalesTaxFgn + TaxAdjAmtFgn
FROM dbo.tblApTransHeader t INNER JOIN #PostTransList l ON t.TransId = l.TransId 
INNER JOIN dbo.tblApDistCode d ON t.DistCode = d.DistCode
WHERE (SalesTax + TaxAdjAmt) <> 0 OR (SalesTaxFgn + TaxAdjAmtFgn) <> 0

--Freight (-2)
INSERT INTO dbo.tblApHistDetail (PostRun, TransID, InvoiceNum
	, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcct
	, ConversionFactor, Qty, QtyBase, UnitCost, ExtCost, UnitCostFgn, ExtCostFgn)
SELECT @PostRun, t.TransId, InvoiceNum
	, -2, 0, WhseId, 0, TaxClassFreight, d.FreightGLAcct
	, 1, 1, 1, Freight, Freight, FreightFgn, FreightFgn
FROM dbo.tblApTransHeader t INNER JOIN #PostTransList l ON t.TransId = l.TransId 
INNER JOIN dbo.tblApDistCode d ON t.DistCode = d.DistCode 
WHERE Freight <> 0 OR FreightFgn <> 0

--Misc (-3)
INSERT INTO dbo.tblApHistDetail (PostRun, TransID, InvoiceNum
	, EntryNum, LineSeq, WhseId, PartType, TaxClass, GLAcct
	, ConversionFactor, Qty, QtyBase, UnitCost, ExtCost, UnitCostFgn, ExtCostFgn)
SELECT @PostRun, t.TransId, InvoiceNum
	, -3, 0, WhseId, 0, TaxClassMisc, d.MiscGLAcct
	, 1, 1, 1, Misc, Misc, MiscFgn, MiscFgn
FROM dbo.tblApTransHeader t INNER JOIN #PostTransList l ON t.TransId = l.TransId 
INNER JOIN dbo.tblApDistCode d ON t.DistCode = d.DistCode 
WHERE Misc <> 0 OR MiscFgn <> 0

-- append detail info to tblApHistDetail
INSERT dbo.tblApHistDetail (PostRun, InvoiceNum, TransID, EntryNum, PartID, PartType, WhseId, [Desc], CostType, GLAcct
, Qty, QtyBase, Units, UnitsBase, UnitCost, UnitCostFgn, ExtCost, ExtCostFgn, GLDesc, AddnlDesc, HistSeqNum, TaxClass
, BinNum, ConversionFactor, LottedYN, InItemYN, GLAcctSales, TransHistId, ExtInc, GLAcctWIP
, CustomerID, JobId, ProjName, PhaseId, PhaseName, TaskId, TaskName,UnitInc,LineSeq,CF) 
SELECT @PostRun, th.InvoiceNum, td.TransID, td.EntryNum, PartID, PartType, td.WhseId, td.[Desc], CostType, GLAcct
, Qty, QtyBase, Units, UnitsBase, UnitCost, UnitCostFgn, ExtCost, ExtCostFgn, GLDesc, AddnlDesc, HistSeqNum, TaxClass
, BinNum, ConversionFactor, LottedYN, InItemYN, GLAcctSales, TransHistId, ExtInc, GLAcctWIP
, CustomerID, JobId, ProjName, PhaseId, PhaseName, TaskId, TaskName,UnitInc,LineSeq,td.CF
FROM (dbo.tblApTransHeader th INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransID) 
	INNER JOIN #PostTransList l ON th.TransId = l.TransId 
	LEFT JOIN dbo.tblApTransPc p ON td.TransID = p.TransId AND td.EntryNum = p.EntryNum
WHERE (@ApJcYn = 0 OR p.TransId IS NULL)

-- transaction allocation detail
IF @TransAllocYn <> 0 
BEGIN
	INSERT dbo.tblApHistAlloc (PostRun, TransId, InvoiceNum, EntryNum, TransAllocId, AcctId, Amount, AmountFgn, CF) 
	SELECT @PostRun, td.TransId, th.InvoiceNum, td.EntryNum, a.TransAllocId, ad.AcctId, ad.Amount, ad.AmountFgn, ad.CF 
	FROM dbo.tblApTransHeader th INNER JOIN dbo.tblApTransDetail td ON th.TransId = td.TransID 
		INNER JOIN dbo.tblApTransAlloc a ON td.TransId = a.TransId AND td.EntryNum = a.EntryNum 
		INNER JOIN dbo.tblApTransAllocDtl ad ON a.TransId = ad.TransId AND a.EntryNum = ad.EntryNum 
		INNER JOIN #PostTransList l ON th.TransId = l.TransId  
END

-- lot
INSERT INTO dbo.tblApHistLot (PostRun, InvoiceNum, TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
, QtyOrder, QtyFilled, QtyBkord, CostUnit, CostUnitFgn, HistSeqNum, Cmnt, CF) 
SELECT @PostRun, th.InvoiceNum, l.TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
, QtyOrder, QtyFilled, QtyBkord, CostUnit, CostUnitFgn, HistSeqNum, Cmnt, l.CF 
FROM dbo.tblApTransHeader th INNER JOIN #PostTransList t ON th.TransId = t.TransId 
INNER JOIN dbo.tblApTransLot l ON th.TransId = l.TransId 

-- ser
INSERT INTO dbo.tblApHistSer (PostRun, InvoiceNum, s.TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
, SerNum, CostUnit, PriceUnit, CostUnitFgn, PriceUnitFgn, HistSeqNum, Cmnt, CF) 
SELECT @PostRun, th.InvoiceNum, s.TransId, EntryNum, SeqNum, ItemId, LocId, LotNum
, SerNum, CostUnit, PriceUnit, CostUnitFgn, PriceUnitFgn, HistSeqNum, Cmnt, s.CF 
FROM dbo.tblApTransHeader th INNER JOIN #PostTransList l ON th.TransId = l.TransId
INNER JOIN dbo.tblApTransSer s ON th.TransId = s.TransId 

-- tax
INSERT INTO dbo.tblApHistInvoiceTax (PostRun, TransId, TaxLocID, TaxClass, ExpAcct, TaxAmt, Refundable
, Taxable, NonTaxable, RefundAcct, InvcNum, TaxAmtFgn, TaxableFgn, NonTaxableFgn, RefundableFgn, CF) 
SELECT @PostRun, th.TransId, TaxLocID, TaxClass, ExpAcct, TaxAmt, Refundable
, t.Taxable, t.NonTaxable, RefundAcct, th.InvoiceNum, TaxAmtFgn, t.TaxableFgn, t.NonTaxableFgn, RefundableFgn, t.CF 
FROM dbo.tblApTransHeader th INNER JOIN #PostTransList l ON th.TransId = l.TransId
INNER JOIN dbo.tblApTransInvoiceTax t ON th.TransId = t.TransId 

-- insert PostRun into tblApHistRecur 
UPDATE dbo.tblApHistRecur SET PostRun = @PostRun
FROM dbo.tblApTransHeader h
	INNER JOIN dbo.tblApHistRecur ON h.TransID = dbo.tblApHistRecur.TransID 
	INNER JOIN #PostTransList l ON h.TransId = l.TransId
	WHERE dbo.tblApHistRecur.PostRun IS NULL AND dbo.tblApHistRecur.Source = 0

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_History_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransPost_History_proc';

