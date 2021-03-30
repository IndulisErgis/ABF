
CREATE PROCEDURE dbo.trav_PoTransPost_InvoiceGlLog_proc
AS
SET NOCOUNT ON
BEGIN TRY
	DECLARE @AccrualYn bit, @Multicurrency bit, @PrecCurr smallint,@PostRun nvarchar(14), 
		@WksDate datetime,@CurrBase pCurrency

	--Retrieve global values
	SELECT @PostRun = Cast([Value] AS nvarchar(14)) FROM #GlobalValues WHERE [Key] = 'PostRun'
	SELECT @WksDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'
	SELECT @CurrBase = Cast([Value] AS nvarchar(6)) FROM #GlobalValues WHERE [Key] = 'CurrBase'
	SELECT @AccrualYn = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'AccrualYn'
	SELECT @Multicurrency = Cast([Value] AS bit) FROM #GlobalValues WHERE [Key] = 'Multicurr'
	SELECT @PrecCurr = Cast([Value] AS smallint) FROM #GlobalValues WHERE [Key] = 'PrecCurr'

	IF @Multicurrency IS NULL OR @AccrualYn IS NULL OR @PrecCurr IS NULL 
		OR @PostRun IS NULL OR @WksDate IS NULL OR @CurrBase IS NULL 
	BEGIN
		RAISERROR(90025,16,1)
	END

	CREATE TABLE #TransPostGlAllTax (
	 TransId nvarchar (8) NOT NULL ,
	 InvcNum nvarchar (15) NOT NULL ,
	 TaxLocID nvarchar (10) NOT NULL ,
	 TaxClass tinyint NOT NULL DEFAULT (0),
	 ExpAcct nvarchar(40) NOT NULL,
	 CurrTaxAmt Decimal(28,10) NULL DEFAULT (0),
	 CurrRefundable Decimal(28,10) NULL DEFAULT (0),
	 CurrTaxable Decimal(28,10) NULL DEFAULT (0),
	 CurrNonTaxable Decimal(28,10) NULL DEFAULT (0),
	 RefundAcct nvarchar (24) NULL ,
	 CurrTaxAmtFgn Decimal(28,10) NULL DEFAULT (0),
	 CurrRefundableFgn Decimal(28,10) NULL DEFAULT (0),
	 CurrTaxableFgn Decimal(28,10) NULL DEFAULT (0),
	 CurrNonTaxableFgn Decimal(28,10) NULL DEFAULT (0),
	 PRIMARY KEY  CLUSTERED (TransId, InvcNum, TaxLocID, TaxClass, ExpAcct)
	)

	INSERT INTO #TransPostGlAllTax 
	SELECT v.TransId, v.InvcNum, v.TaxLocID, TaxClass, v.ExpAcct, v.CurrTaxAmt, v.CurrRefundable, v.CurrTaxable, v.CurrNonTaxable, 
	 v.RefundAcct, v.CurrTaxAmtFgn, v.CurrRefundableFgn, v.CurrTaxableFgn, v.CurrNonTaxableFgn 
	FROM #PostTransList l INNER JOIN dbo.tblPoTransInvoiceTot t ON l.TransID = t.TransId 
		INNER JOIN dbo.tblPoTransInvoiceTax v ON t.TransId = v.TransId AND t.InvcNum = v.InvcNum
		LEFT JOIN (SELECT TransID, InvoiceNum FROM dbo.tblPoTransInvoice WHERE [Status] = 0 GROUP BY TransID, InvoiceNum) i
			 ON t.TransId = i.TransID AND t.InvcNum = i.InvoiceNum 
	WHERE t.CurrSalesTaxfgn != 0 OR t.CurrFreightfgn != 0 OR  t.CurrMiscfgn != 0 OR  t.CurrTaxAdjAmtfgn <> 0 OR t.CurrPrepaidFgn <> 0 OR i.TransID IS NOT NULL 

	INSERT INTO #TransPostGlAllTax 
	(TransId, InvcNum, TaxLocId, TaxClass, ExpAcct,
	CurrTaxAmt, CurrRefundable, CurrTaxable, CurrNonTaxable, RefundAcct)
	SELECT t.TransId, t.InvcNum, t.CurrTaxAdjLocID, t.CurrTaxAdjClass, td.ExpenseAcct,
	 0, 0, 0, 0, l.TaxRefAcct 
	FROM (dbo.tblPoTransInvoiceTot t INNER JOIN #PostTransList i ON t.TransId = i.TransID) 
	INNER JOIN tblSmTaxLoc l ON t.CurrTaxAdjLocID = l.TaxLocId 
	INNER JOIN tblSmTaxLocDetail td ON t.CurrTaxAdjLocID=td.TaxLocID AND
	 t.CurrTaxAdjClass=td.TaxClassCode
	LEFT JOIN #TransPostGlAllTax tx ON t.transid=tx.transid AND t.InvcNum=tx.InvcNum
	 AND t.CurrTaxAdjLocID=tx.TaxLocID AND t.CurrTaxAdjClass=tx.taxclass and 
	 td.expenseacct=tx.expacct
	WHERE tx.transid is null

	UPDATE #TransPostGlAllTax 
	SET CurrTaxAmt = CurrTaxAmt + CurrTaxAdjAmt, CurrTaxAmtfgn  = CurrTaxAmtfgn  + CurrTaxAdjAmtfgn 
	FROM tblPoTransInvoiceTot t INNER JOIN #TransPostGlAllTax 
	ON #TransPostGlAllTax.TaxClass = t.CurrTaxAdjClass 
	 AND #TransPostGlAllTax.TaxLocID = t.CurrTaxAdjLocID 
	 AND #TransPostGlAllTax.InvcNum = t.InvcNum 
	 AND #TransPostGlAllTax.TransId = t.TransId  
	 INNER JOIN tblSmTaxLocDetail td ON (td.ExpenseAcct = #TransPostGlAllTax.ExpAcct) 
	 AND (t.CurrTaxAdjClass = td.TaxClassCode) AND (t.CurrTaxAdjLocID = td.TaxLocId)

	/* make detail entries */

	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, t.TransID, t.InvcNum,  t.GlPeriod, d.EntryNum, CASE WHEN ISNULL(d.ProjectDetailId,0) = 0 THEN 10 ELSE 9999 END, --Temprary entry for PC
	 CASE WHEN h.TransType >= 0 THEN v.ExtCost ELSE -v.ExtCost END, 
	 CASE WHEN h.TransType >= 0 THEN v.ExtCostFgn ELSE -v.ExtCostFgn END, 
	 t.InvcDate, @WksDate, 
	 CASE WHEN d.GLDesc IS NOT NULL THEN SUBSTRING(d.GLDesc,1,30) 
	   WHEN d.Descr IS NOT NULL THEN SUBSTRING(d.Descr,1,30) 
	   ELSE t.InvcNum END, 
	 h.VendorID, d.GLAcct, 
	 CASE WHEN v.ExtCost > 0 AND h.TransType > 0 THEN v.ExtCost 
	  WHEN v.ExtCost < 0 AND h.TransType < 0 THEN -v.ExtCost ELSE 0 END, 
	 CASE WHEN v.ExtCost > 0 AND h.TransType < 0 THEN v.ExtCost 
	  WHEN v.ExtCost < 0 AND h.TransType > 0 THEN -v.ExtCost ELSE 0 END, 
	 t.FiscalYear, t.TransID, t.InvcNum, d.EntryNum,
	 @CurrBase, 1,
	CASE WHEN v.ExtCost > 0 AND h.TransType > 0 THEN v.ExtCost 
	  WHEN v.ExtCost < 0 AND h.TransType < 0 THEN -v.ExtCost ELSE 0 END, 
	 CASE WHEN v.ExtCost > 0 AND h.TransType < 0 THEN v.ExtCost 
	  WHEN v.ExtCost < 0 AND h.TransType > 0 THEN -v.ExtCost ELSE 0 END 
	FROM (#PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
	 INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId)
	INNER JOIN (dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransInvoice v
	ON d.EntryNum = v.EntryNum AND d.TransID = v.TransID) 
	ON t.TransID = d.TransID and t.InvcNum = v.InvoiceNum 
	WHERE v.Status=0 AND v.ExtCost <> 0 AND (h.DropShipYn = 0 OR ISNULL(d.LinkSeqNum,0) = 0)

	--When use accrual, following entries will be deleted later.
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, t.TransID, t.InvcNum, 
	 t.GlPeriod, d.EntryNum, CASE WHEN @AccrualYn = 1 THEN 9999 ELSE 10 END, 
	 CASE WHEN h.TransType >= 0 THEN v.ExtCost ELSE -v.ExtCost END, 
	 CASE WHEN h.TransType >= 0 THEN v.ExtCostFgn ELSE -v.ExtCostFgn END, 
	 t.InvcDate, @WksDate, 
	 CASE WHEN d.GLDesc IS NOT NULL THEN SUBSTRING(d.GLDesc,1,30) 
	   WHEN d.Descr IS NOT NULL THEN SUBSTRING(d.Descr,1,30) 
	   ELSE t.InvcNum END, 
	 h.VendorID, d.GLAcct, 
	 CASE WHEN v.ExtCost > 0 AND h.TransType > 0 THEN v.ExtCost 
	  WHEN v.ExtCost < 0 AND h.TransType < 0 THEN -v.ExtCost ELSE 0 END, 
	 CASE WHEN v.ExtCost > 0 AND h.TransType < 0 THEN v.ExtCost 
	  WHEN v.ExtCost < 0 AND h.TransType > 0 THEN -v.ExtCost ELSE 0 END, 
	 t.FiscalYear, t.TransID, t.InvcNum, d.EntryNum,
	 @CurrBase, 1,
	CASE WHEN v.ExtCost > 0 AND h.TransType > 0 THEN v.ExtCost 
	  WHEN v.ExtCost < 0 AND h.TransType < 0 THEN -v.ExtCost ELSE 0 END, 
	 CASE WHEN v.ExtCost > 0 AND h.TransType < 0 THEN v.ExtCost 
	  WHEN v.ExtCost < 0 AND h.TransType > 0 THEN -v.ExtCost ELSE 0 END 
	FROM (#PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
	 INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId)
	INNER JOIN (dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransInvoice v
	ON d.EntryNum = v.EntryNum AND d.TransID = v.TransID) 
	ON t.TransID = d.TransID and t.InvcNum = v.InvoiceNum 
	WHERE v.Status=0 AND v.ExtCost <> 0 AND ISNULL(d.ProjectDetailId,0) = 0 AND 
		(h.DropShipYn = 1 AND ISNULL(d.LinkSeqNum,0) > 0)

	/* make tax entries */
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, t.TransID, t.InvcNum, 
	 t.GlPeriod, 99999, 101, 
	 CASE WHEN h.TransType >= 0 THEN d.CurrTaxAmt ELSE -d.CurrTaxAmt END, 
	 CASE WHEN h.TransType >= 0 THEN d.CurrTaxAmtFgn ELSE -d.CurrTaxAmtfgn END, 
	 t.InvcDate, @WksDate, 
	 'Tax Loc' + ' ' + d.TaxLocID + ' - ' + CONVERT(nvarchar(3), d.TaxClass), 
	 h.VendorID,d.ExpAcct,
	 CASE WHEN d.CurrTaxAmt > 0 AND h.TransType > 0 THEN d.CurrTaxAmt 
	  WHEN d.CurrTaxAmt < 0 AND h.TransType < 0 THEN -d.CurrTaxAmt ELSE 0 END, 
	 CASE WHEN d.CurrTaxAmt > 0 AND h.TransType < 0 THEN d.CurrTaxAmt 
	  WHEN d.CurrTaxAmt < 0 AND h.TransType > 0 THEN -d.CurrTaxAmt ELSE 0 END, 
	 t.FiscalYear, t.TransID, t.InvcNum, 0, @CurrBase, 1,
	 CASE WHEN d.CurrTaxAmt > 0 AND h.TransType > 0 THEN d.CurrTaxAmt 
	  WHEN d.CurrTaxAmt < 0 AND h.TransType < 0 THEN -d.CurrTaxAmt ELSE 0 END, 
	 CASE WHEN d.CurrTaxAmt > 0 AND h.TransType < 0 THEN d.CurrTaxAmt 
	  WHEN d.CurrTaxAmt < 0 AND h.TransType > 0 THEN -d.CurrTaxAmt ELSE 0 END 
	FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId 
	INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
	INNER JOIN #TransPostGlAllTax d ON t.TransID = d.TransID AND t.InvcNum = d.InvcNum 
	WHERE CurrTaxAmt <> 0

	/* make entries for refundable tax amounts */
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, t.TransID, t.InvcNum, t.GlPeriod, 99999, 101, 
	 CASE WHEN h.TransType >= 0 THEN -d.CurrRefundable ELSE d.CurrRefundable END, 
	 CASE WHEN h.TransType >= 0 THEN -d.CurrRefundableFgn ELSE d.CurrRefundableFgn END, 
	 t.InvcDate, @WksDate, 
	 'Tax Loc' + ' ' + d.TaxLocID + ' - ' + CONVERT(nvarchar(3), d.TaxClass), 
	 h.VendorID,d.ExpAcct,
	 CASE WHEN d.CurrRefundable < 0 AND h.TransType > 0 THEN -d.CurrRefundable 
	  WHEN d.CurrRefundable > 0 AND h.TransType < 0 THEN d.CurrRefundable ELSE 0 END, 
	 CASE WHEN d.CurrRefundable < 0 AND h.TransType < 0 THEN -d.CurrRefundable
	  WHEN  d.CurrRefundable > 0 AND h.TransType > 0 THEN d.CurrRefundable ELSE 0 END, 
	 t.FiscalYear, t.TransID, t.InvcNum, 0,	 @CurrBase, 1,
	 CASE WHEN d.CurrRefundable < 0 AND h.TransType > 0 THEN -d.CurrRefundable 
	  WHEN d.CurrRefundable > 0 AND h.TransType < 0 THEN d.CurrRefundable ELSE 0 END, 
	 CASE WHEN d.CurrRefundable < 0 AND h.TransType < 0 THEN -d.CurrRefundable
	  WHEN  d.CurrRefundable > 0 AND h.TransType > 0 THEN d.CurrRefundable ELSE 0 END
	FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
	 INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
	INNER JOIN #TransPostGlAllTax d ON t.TransID = d.TransID AND t.InvcNum = d.InvcNum 
	WHERE d.CurrRefundable <> 0

	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum,	GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, t.TransID, t.InvcNum, 
	 t.GlPeriod, 99999, 101, 
	 CASE WHEN h.TransType >= 0 THEN d.CurrRefundable ELSE -d.CurrRefundable END, 
	 CASE WHEN h.TransType >= 0 THEN d.CurrRefundableFgn ELSE -d.CurrRefundableFgn END, 
	 t.InvcDate, @WksDate, 
	 'Tax Refund' + ' ' + d.TaxLocID + ' - ' + CONVERT(nvarchar(3), d.TaxClass), 
	 h.VendorID, RefundAcct, 
	 CASE WHEN d.CurrRefundable > 0 AND h.TransType > 0 THEN d.CurrRefundable 
	  WHEN d.CurrRefundable < 0 AND h.TransType < 0 THEN -d.CurrRefundable ELSE 0 END, 
	 CASE WHEN d.CurrRefundable > 0 AND h.TransType < 0 THEN d.CurrRefundable 
	  WHEN d.CurrRefundable < 0 AND h.TransType > 0 THEN -d.CurrRefundable ELSE 0 END, 
	 t.FiscalYear, t.TransID, t.InvcNum, 0,	 @CurrBase, 1,
	 CASE WHEN d.CurrRefundable > 0 AND h.TransType > 0 THEN d.CurrRefundable 
	  WHEN d.CurrRefundable < 0 AND h.TransType < 0 THEN -d.CurrRefundable ELSE 0 END, 
	 CASE WHEN d.CurrRefundable > 0 AND h.TransType < 0 THEN d.CurrRefundable 
	  WHEN d.CurrRefundable < 0 AND h.TransType > 0 THEN -d.CurrRefundable ELSE 0 END 
	FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
	 INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId
	INNER JOIN #TransPostGlAllTax d 
	 ON t.TransID = d.TransID AND t.InvcNum = d.InvcNum 
	WHERE d.CurrRefundable <> 0

	/* make Frt entry */
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, t.TransID, t.InvcNum, t.GlPeriod, 99999, 102, 
	 CASE WHEN h.TransType >= 0 THEN CurrFreight ELSE -CurrFreight END, 
	 CASE WHEN h.TransType >= 0 THEN CurrFreightFgn ELSE -CurrFreightFgn END, 
	 t.InvcDate, @WksDate, 
	 'Freight', h.VendorID, FreightGLAcct, 
	 CASE WHEN CurrFreight > 0 AND h.TransType > 0 THEN CurrFreight 
	  WHEN CurrFreight < 0 AND h.TransType < 0 THEN -CurrFreight ELSE 0 END, 
	 CASE WHEN CurrFreight > 0 AND h.TransType < 0 THEN CurrFreight 
	  WHEN CurrFreight < 0 AND h.TransType > 0 THEN -CurrFreight ELSE 0 END, 
	 t.FiscalYear, t.TransID, t.InvcNum, 0,	 @CurrBase, 1,
	CASE WHEN CurrFreight > 0 AND h.TransType > 0 THEN CurrFreight 
	  WHEN CurrFreight < 0 AND h.TransType < 0 THEN -CurrFreight ELSE 0 END, 
	 CASE WHEN CurrFreight > 0 AND h.TransType < 0 THEN CurrFreight 
	  WHEN CurrFreight < 0 AND h.TransType > 0 THEN -CurrFreight ELSE 0 END 
	FROM #PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId
	INNER JOIN dbo.tblApDistCode c ON h.DistCode = c.DistCode
	INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId 
	WHERE CurrFreight <> 0

	/* make Misc entry */
	INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum, GlPeriod, EntryNum, Grouping, 
	Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
	LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
	SELECT @PostRun, t.TransID, t.InvcNum, t.GlPeriod, 99999, 103, 
	 CASE WHEN h.TransType >= 0 THEN CurrMisc ELSE -CurrMisc END, 
	 CASE WHEN h.TransType >= 0 THEN CurrMiscFgn ELSE -CurrMiscFgn END, 
	 t.InvcDate, @WksDate, 
	 'Misc', h.VendorID, MiscGLAcct, 
	 CASE WHEN CurrMisc > 0 AND h.TransType > 0 THEN CurrMisc 
	  WHEN CurrMisc < 0 AND h.TransType < 0 THEN -CurrMisc ELSE 0 END, 
	 CASE WHEN CurrMisc > 0 AND h.TransType < 0 THEN CurrMisc 
	  WHEN CurrMisc < 0 AND h.TransType > 0 THEN -CurrMisc ELSE 0 END, 
	 t.FiscalYear, t.TransID, t.InvcNum, 0, @CurrBase, 1,
	 CASE WHEN CurrMisc > 0 AND h.TransType > 0 THEN CurrMisc 
	  WHEN CurrMisc < 0 AND h.TransType < 0 THEN -CurrMisc ELSE 0 END, 
	 CASE WHEN CurrMisc > 0 AND h.TransType < 0 THEN CurrMisc 
	  WHEN CurrMisc < 0 AND h.TransType > 0 THEN -CurrMisc ELSE 0 END 
	FROM (#PostTransList i INNER JOIN dbo.tblPoTransHeader h ON i.TransId = h.TransId 
		 INNER JOIN dbo.tblApDistCode c ON h.DistCode = c.DistCode)
		INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransID = t.TransId 
	WHERE CurrMisc <> 0

	/* Make header entry */

	If @Multicurrency  = 1
	BEGIN

		INSERT INTO #PoTransPostGlLog (PostRun,  GlPeriod, EntryNum, Grouping, Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, 
			DR, CR, FiscalYear, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn, LinkID, LinkIDSub)
		SELECT @PostRun, g.GlPeriod, 99999, 104, - Sum(convert(Decimal(28,10),Amount)), 
		Case when h.CurrencyId = @CurrBase then	 - Sum(convert(Decimal(28,10),Amount)) 
		else  - Sum(convert(Decimal(28,10),Amountfgn)) end, min(InvcDate), @WksDate,  'AP', 'AP', PayablesGLAcct, 
		 CASE WHEN - Sum(convert(Decimal(28,10),Amount)) > 0 THEN - Sum(convert(Decimal(28,10),Amount)) ELSE 0 END, 
		 CASE WHEN - Sum(convert(Decimal(28,10),Amount)) < 0 THEN Sum(convert(Decimal(28,10),Amount)) ELSE 0 END, 
		 g.FiscalYear,  0, 
		 CASE WHEN h.CurrencyId IS NULL THEN @CurrBase ELSE h.CurrencyId END, Case when h.CurrencyId = @CurrBase OR h.CurrencyId IS NULL then 1 ELSE t.InvoiceExchRate END,
		 Case when h.CurrencyId = @CurrBase OR h.CurrencyId IS NULL then
		 (CASE WHEN - Sum(convert(Decimal(28,10),Amount)) > 0 THEN 
		  - Sum(convert(Decimal(28,10),Amount)) ELSE 0 END) else
		 (CASE WHEN - Sum(convert(Decimal(28,10),Amountfgn)) > 0 THEN 
		  - Sum(convert(Decimal(28,10),Amountfgn)) ELSE 0 END) END, 
		Case when h.CurrencyId = @CurrBase  OR h.CurrencyId IS NULL then
		 (CASE WHEN - Sum(convert(Decimal(28,10),Amount)) < 0 THEN 
		  Sum(convert(Decimal(28,10),Amount)) ELSE 0 END) else 
		(CASE WHEN - Sum(convert(Decimal(28,10),Amountfgn)) < 0 THEN 
		  Sum(convert(Decimal(28,10),Amountfgn)) ELSE 0 END) end,
		t.TransID, t.InvcNum
		FROM (((#PostTransList i INNER JOIN dbo.tblPoTransHeader  p ON i.TransId = p.TransId
		INNER JOIN dbo.tblApDistCode c ON p.DistCode = c.DistCode)
		LEFT Join dbo.tblGlAcctHdr h on  c.PayablesGLAcct =  h.AcctId)
		INNER JOIN dbo.tblPoTransInvoiceTot t ON p.TransID = t.TransId)
		INNER JOIN #PoTransPostGlLog g ON t.TransID = g.TransID AND t.InvcNum = g.InvcNum
		GROUP BY g.FiscalYear,g.GlPeriod, c.PayablesGLAcct, t.TransID, t.InvcNum, h.CurrencyId, t.InvoiceExchRate
		HAVING Sum(convert(Decimal(28,10),Amount)) <> 0
	END
	ELSE
	BEGIN

		INSERT INTO #PoTransPostGlLog (PostRun, GlPeriod, EntryNum, Grouping, 
		Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, LinkIDSubLine, CurrencyId, ExchRate, DebitAmtFgn, CreditAmtFgn)
		SELECT @PostRun, g.GlPeriod, 99999, 104, - Sum(convert(Decimal(28,10),Amount)), 
		Case when h.CurrencyId = @CurrBase then - Sum(convert(Decimal(28,10),Amount)) 
		else  - Sum(convert(Decimal(28,10),Amountfgn)) end, 
		min(InvcDate), @WksDate, 'AP', 'AP', PayablesGLAcct, 
		 CASE WHEN - Sum(convert(Decimal(28,10),Amount)) > 0 THEN - Sum(convert(Decimal(28,10),Amount)) ELSE 0 END, 
		 CASE WHEN - Sum(convert(Decimal(28,10),Amount)) < 0 THEN Sum(convert(Decimal(28,10),Amount)) ELSE 0 END, 
		 g.FiscalYear,  0, @CurrBase, 1,
		 (CASE WHEN - Sum(convert(Decimal(28,10),Amount)) > 0 THEN 
		  - Sum(convert(Decimal(28,10),Amount)) ELSE 0 END) , 
		 (CASE WHEN - Sum(convert(Decimal(28,10),Amount)) < 0 THEN 
		  Sum(convert(Decimal(28,10),Amount)) ELSE 0 END) 
		FROM (((#PostTransList i INNER JOIN dbo.tblPoTransHeader  p ON i.TransId = p.TransId
		INNER JOIN dbo.tblApDistCode c ON p.DistCode = c.DistCode)
		LEFT Join dbo.tblGlAcctHdr h on  c.PayablesGLAcct =  h.AcctId)
		INNER JOIN dbo.tblPoTransInvoiceTot t ON p.TransID = t.TransId)
		INNER JOIN #PoTransPostGlLog g ON t.TransID = g.TransID AND t.InvcNum = g.InvcNum
		GROUP BY g.FiscalYear,g.GlPeriod, c.PayablesGLAcct, h.CurrencyId, t.InvoiceExchRate
		HAVING Sum(convert(Decimal(28,10),Amount)) <> 0

	END

	IF @AccrualYn = 1 --Drop ship
	BEGIN
		--Difference between invoice cost and receipt cost per tblPoTransInvoice record.
		INSERT INTO #PoTransPostGlLog (PostRun, TransID, InvcNum,GlPeriod, EntryNum, Grouping, 
		Amount, Amountfgn, TransDate, PostDate, Descr, Reference, GlAcct, DR, CR, FiscalYear, 
		LinkID, LinkIDSub, LinkIDSubLine, CurrencyId, ExchRate,  DebitAmtFgn, CreditAmtFgn)
		SELECT @PostRun,d.TransId, i.InvoiceNum, t.GlPeriod, d.EntryNum, 10,
		SIGN(h.TransType) * (i.ExtCost - r.RcptCost), SIGN(h.TransType) * (i.ExtCost - r.RcptCost),
		t.InvcDate,@WksDate,SUBSTRING(d.Descr,1,30),h.VendorId,d.GlAcct,
		CASE WHEN SIGN(h.TransType) * (i.ExtCost - r.RcptCost) > 0 THEN SIGN(h.TransType) * (i.ExtCost - r.RcptCost) ELSE 0 END,
		CASE WHEN SIGN(h.TransType) * (i.ExtCost - r.RcptCost) > 0 THEN 0 ELSE ABS(SIGN(h.TransType) * (i.ExtCost - r.RcptCost)) END,
		t.FiscalYear,d.TransId, i.InvoiceNum, d.EntryNum, @CurrBase, 1,
		CASE WHEN SIGN(h.TransType) * (i.ExtCost - r.RcptCost) > 0 THEN SIGN(h.TransType) * (i.ExtCost - r.RcptCost) ELSE 0 END,
		CASE WHEN SIGN(h.TransType) * (i.ExtCost - r.RcptCost) > 0 THEN 0 ELSE ABS(SIGN(h.TransType) * (i.ExtCost - r.RcptCost)) END 
		FROM #PostTransList b INNER JOIN dbo.tblPoTransHeader  h ON b.TransId = h.TransId 
			INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId
			INNER JOIN dbo.tblPoTransInvoice i ON t.TransId = i.TransId AND t.InvcNum = i.InvoiceNum 
			INNER JOIN dbo.tblPoTransDetail d ON i.TransId = d.TransId AND i.EntryNum = d.EntryNum
			INNER JOIN (SELECT i.InvoiceID, SUM(ROUND(i.Qty * r.ExtCost / r.QtyFilled, @PrecCurr)) AS RcptCost
				FROM dbo.tblPoTransLotRcpt r INNER JOIN dbo.tblPoTransInvc_Rcpt i ON r.ReceiptID = i.ReceiptID
				GROUP BY i.InvoiceID) r ON i.InvoiceID = r.InvoiceID
		WHERE ISNULL(d.ProjectDetailId,0) = 0 AND d.ItemType IN (0,1,3) AND i.Status = 0 AND (h.DropShipYn = 1 AND ISNULL(d.LinkSeqNum,0) > 0) AND (i.ExtCost - r.RcptCost) <> 0 
		UNION ALL
		SELECT @PostRun,d.TransId, i.InvoiceNum, t.GlPeriod, d.EntryNum, 10,
		SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)),SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)),
		t.InvcDate,@WksDate,SUBSTRING(d.Descr,1,30),h.VendorId,d.GlAcct,
		CASE WHEN SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)) > 0 THEN SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)) ELSE 0 END,
		CASE WHEN SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)) > 0 THEN 0 ELSE ABS(SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr))) END,
		t.FiscalYear,d.TransId, i.InvoiceNum, d.EntryNum, @CurrBase, 1,
		CASE WHEN SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)) > 0 THEN SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)) ELSE 0 END,
		CASE WHEN SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)) > 0 THEN 0 ELSE ABS(SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr))) END 
		FROM #PostTransList  b INNER JOIN dbo.tblPoTransHeader  h ON b.TransId = h.TransId 
			INNER JOIN dbo.tblPoTransInvoiceTot t ON h.TransId = t.TransId
			INNER JOIN (dbo.tblPoTransDetail d INNER JOIN dbo.tblPoTransInvoice i ON d.TransId = i.TransId AND d.EntryNum = i.EntryNum) 
			ON t.TransId = i.TransId AND t.InvcNum = i.InvoiceNum
			INNER JOIN dbo.tblPoTransSer s ON i.TransId = s.TransId AND i.EntryNum = s.EntryNum AND i.InvoiceNum = s.InvcNum 
			INNER JOIN dbo.tblInItemLoc l ON d.ItemId = l.ItemId AND d.LocId = l.LocId 
		WHERE d.InItemYn = 1 AND ISNULL(d.ProjectDetailId,0) = 0 AND (h.DropShipYn = 1 AND ISNULL(d.LinkSeqNum,0) > 0)
			AND d.ItemType = 2 AND i.Status = 0 AND s.InvcStatus = 0 AND ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr) <> 0 
		GROUP BY d.TransId, d.EntryNum,i.InvoiceNum, t.FiscalYear, t.GlPeriod, t.InvcDate , d.Descr, h.VendorId,d.GlAcct
		HAVING SUM(SIGN(h.TransType) * ROUND(s.InvcUnitCost - s.RcptUnitCost, @PrecCurr)) <> 0

	END

	--Remove drop ship entries after make AP entries when use accrual or PC temporary entry
	DELETE #PoTransPostGlLog WHERE [Grouping] = 9999

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_InvoiceGlLog_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransPost_InvoiceGlLog_proc';

