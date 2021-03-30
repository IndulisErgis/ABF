
CREATE PROCEDURE dbo.trav_PoTransactionJournal_proc
@SortBy int = 0, 
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null,
@PrintPurchasesJournal bit = 1,
@PrintDetail bit = 1
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpPurchases
	(
		TransId pTransID NOT NULL, 
		InvoiceNum pInvoiceNum NOT NULL
	)

	CREATE TABLE #tmpPurchaseDetail
	(
		RecType tinyint, 
		TransId pTransID, 
		BatchId pBatchID, 
		VendorId pVendorID, 
		DistCode pDistCode, 
		TaxGrpId pTaxLoc, 
		EntryNum smallint, 
		GlAcct pGlAcct NULL, 
		ItemId pItemID NULL, 
		ItemType tinyint NULL, 
		ProjId pProjID NULL, 
		CustId pCustID NULL, 
		PhaseId pPhaseID NULL, 
		TaskId pTaskID NULL, 
		LocIdDtl pLocID NULL, 
		Descr pDescription NULL, 
		Units pUom NULL, 
		GlDesc pGLDesc NULL, 
		AddnlDescr nvarchar(max) NULL, 
		TaxClass tinyint NULL, 
		InvoiceNum pInvoiceNum, 
		InvoiceDate datetime NULL, 
		FiscalPeriod smallint NULL, 
		FiscalYear smallint NULL, 
		Qty pDecimal NULL, 
		UnitCost pDecimal NULL, 
		ExtCost pDecimal NULL, 
		Ten99InvoiceYN bit NULL, 
		CurrTaxable pDecimal NULL, 
		CurrNonTaxable pDecimal NULL, 
		CurrSalesTax pDecimal NULL, 
		CurrFreight pDecimal NULL, 
		CurrMisc pDecimal NULL, 
		CurrDisc pDecimal NULL, 
		CurrPrepaid pDecimal NULL, 
		CurrTotal pDecimal NULL, 
		GroupHeader0 int NULL, 
		CurrCheckNo pCheckNum NULL, 
		CurrCheckDate datetime NULL, 
		CurrDueDate1 datetime NULL, 
		CurrDueDate2 datetime NULL, 
		CurrDueDate3 datetime NULL, 
		CurrPmtAmt1 pDecimal NULL, 
		CurrPmtAmt2 pDecimal NULL, 
		CurrPmtAmt3 pDecimal NULL,
		LottedYn bit NULL,
		GLAcctAccrual pGlAcct NULL,
		WIPAcct pGlAcct NULL
	)

	CREATE TABLE #TempProject
	( 
		TransId pTransId NOT NULL,
		EntryNum int NOT NULL,
		ProjId nvarchar(10) NULL,
		PhaseId nvarchar(10) NULL,
		TaskId nvarchar(10) NULL,
		CustId nvarchar(10) NULL,
		WIPAcct pGlAcct NULL,
		PRIMARY KEY CLUSTERED ([TransId], [EntryNum])
	)
	
	--direct project
	INSERT INTO #TempProject(TransId, EntryNum, ProjId, PhaseId, TaskId, CustId, WIPAcct)
	SELECT d.TransID, d.EntryNum, p.ProjectName, j.PhaseId, j.TaskId, p.CustId, c.GLAcctWIP
	FROM #tmpTransactionList l INNER JOIN dbo.tblPoTransHeader h ON l.TransId = h.TransId 
		INNER JOIN #tmpVendorList v ON h.VendorId = v.VendorId 
		INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON l.TransId = d.TransID 
		INNER JOIN dbo.tblPcProjectDetail j ON d.ProjectDetailId = j.Id 
		INNER JOIN dbo.tblPcProject p ON j.ProjectId = p.Id
		INNER JOIN dbo.tblPcDistCode c ON j.DistCode = c.DistCode
	WHERE h.TransType <> 0
		
	--project link		
	INSERT INTO #TempProject(TransId, EntryNum, ProjId, PhaseId, TaskId, CustId, WIPAcct)
	SELECT d.TransID, d.EntryNum, p.ProjectName, j.PhaseId, j.TaskId, p.CustId, c.GLAcctWIP
	FROM #tmpTransactionList l INNER JOIN dbo.tblPoTransHeader h ON l.TransId = h.TransId 
		INNER JOIN #tmpVendorList v ON h.VendorId = v.VendorId 
		INNER JOIN dbo.tblPoTransDetail d (NOLOCK) ON l.TransId = d.TransID 
		INNER JOIN dbo.tblSmTransLink k ON d.LinkSeqNum = k.SeqNum 
		INNER JOIN dbo.tblPcTrans t ON k.SourceId = t.Id
		INNER JOIN dbo.tblPcProjectDetail j ON t.ProjectDetailId = j.Id 
		INNER JOIN dbo.tblPcProject p ON j.ProjectId = p.Id	
		INNER JOIN dbo.tblPcDistCode c ON j.DistCode = c.DistCode
	WHERE k.TransLinkType = 0 AND k.SourceType = 3 AND k.DestType = 2 AND h.TransType <> 0 --Link between Project and PO order
		AND k.SourceStatus <> 2 AND k.DestStatus <> 2 --link is not broken
	
	INSERT INTO #tmpPurchases (TransId, InvoiceNum) 
	SELECT i.TransId, i.InvcNum 
	FROM #tmpTransactionList t INNER JOIN dbo.tblPoTransHeader h ON t.TransId = h.TransId 
		INNER JOIN #tmpVendorList v ON h.VendorId = v.VendorId 
		INNER JOIN dbo.tblPoTransInvoiceTot i ON t.TransID = i.TransId 
		LEFT JOIN (SELECT TransID, InvoiceNum FROM dbo.tblPoTransInvoice WHERE [Status] = 0 GROUP BY TransID, InvoiceNum) d 
			ON i.TransId = d.TransID AND i.InvcNum = d.InvoiceNum
	WHERE (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
		AND ((@PrintPurchasesJournal = 0 AND h.TransType < 0) OR (@PrintPurchasesJournal = 1 AND h.TransType > 0))
		AND (d.TransID IS NOT NULL OR i.CurrPrepaidFgn <> 0 OR (i.CurrPmtAmt1Fgn + i.CurrPmtAmt2Fgn + i.CurrPmtAmt3Fgn) <> 0)

	IF @SortBy < 2 
	BEGIN
		INSERT INTO #tmpPurchaseDetail (RecType, TransId, BatchId, VendorId, DistCode, TaxGrpId
			, EntryNum, GlAcct, WIPAcct, ItemId, ItemType
			, ProjId, CustId, PhaseId, TaskId, LocIdDtl, Descr, Units
			, GlDesc, AddnlDescr, TaxClass, InvoiceNum
			, InvoiceDate, FiscalPeriod, FiscalYear, Qty, UnitCost, ExtCost, Ten99InvoiceYn
			, CurrTaxable, CurrNonTaxable, CurrSalesTax, CurrFreight, CurrMisc, CurrDisc, CurrPrepaid
			, CurrTotal, GroupHeader0, CurrCheckNo, CurrCheckDate
			, CurrDueDate1, CurrDueDate2, CurrDueDate3, CurrPmtAmt1, CurrPmtAmt2, CurrPmtAmt3,LottedYn, GLAcctAccrual ) 
		SELECT 0 AS RecType, h.TransId, h.BatchId, h.VendorId, h.DistCode, h.TaxGrpID, d.EntryNum, 
			d.GLAcct, e.WIPAcct, --this is actual account that is used in posting for job cost project
			d.ItemId, d.ItemType, e.ProjId, e.CustId, e.PhaseId, e.TaskId, d.LocId AS LocIdDtl, d.Descr, d.Units
			, d.GLDesc, d.AddnlDescr, d.TaxClass, i.InvoiceNum
			, t.InvcDate, t.GlPeriod AS FiscalPeriod, t.FiscalYear, i.Qty
			, CASE WHEN @PrintAllInBase = 1 THEN i.UnitCost ELSE i.UnitCostFgn END AS UnitCost
			, CASE WHEN @PrintAllInBase = 1 THEN i.ExtCost ELSE i.ExtCostFgn END AS ExtCost
			, t.Ten99InvoiceYN
			, 0 AS CurrTaxable
			, 0 AS CurrNonTaxable
			, 0 AS CurrSalesTax
			, 0 AS CurrFreight
			, 0 AS CurrMisc
			, 0 AS CurrDisc 
			, 0 AS CurPrepaid
			, 0 AS CurrTotal
			, COALESCE(d.LineSeq, d.EntryNum) AS GroupHeader0
			, t.CurrCheckNo, t.CurrCheckDate, t.CurrDueDate1, t.CurrDueDate2, t.CurrDueDate3
			, 0 AS CurrPmtAmt1
			, 0 AS CurrPmtAmt2
			, 0 AS CurrPmtAmt3, d.LottedYn, d.GLAcctAccrual
		FROM #tmpPurchases p INNER JOIN dbo.tblPoTransHeader h ON p.TransId = h.TransId
			INNER JOIN dbo.tblPoTransInvoiceTot t ON p.TransID = t.TransId AND p.InvoiceNum = t.InvcNum 
			INNER JOIN dbo.tblPoTransInvoice i ON  t.TransID = i.TransID AND t.InvcNum = i.InvoiceNum 
			INNER JOIN dbo.tblPoTransDetail d ON i.TransId = d.TransID AND i.EntryNum = d.EntryNum 
			LEFT JOIN #TempProject e ON d.TransID = e.TransId AND d.EntryNum = e.EntryNum
		WHERE i.Status = 0
	END
	ELSE
	BEGIN
		INSERT INTO #tmpPurchaseDetail (RecType, TransId, BatchId, VendorId, DistCode, TaxGrpId
			, EntryNum, GlAcct, WIPAcct, ItemId, ItemType
			, ProjId, CustId, PhaseId, TaskId, LocIdDtl, Descr, Units
			, GlDesc, AddnlDescr, TaxClass, InvoiceNum
			, InvoiceDate, FiscalPeriod, FiscalYear, Qty, UnitCost, ExtCost, Ten99InvoiceYn
			, CurrTaxable, CurrNonTaxable, CurrSalesTax, CurrFreight, CurrMisc, CurrDisc, CurrPrepaid
			, CurrTotal, GroupHeader0, CurrCheckNo, CurrCheckDate
			, CurrDueDate1, CurrDueDate2, CurrDueDate3, CurrPmtAmt1, CurrPmtAmt2, CurrPmtAmt3,LottedYn, GLAcctAccrual ) 
		SELECT 0 AS RecType, h.TransId, h.BatchId, h.VendorId, h.DistCode, h.TaxGrpID, d.EntryNum
			,d.GLAcct, e.WIPAcct --this is actual account that is used in posting for job cost project
			,d.ItemId, d.ItemType, e.ProjId, e.CustId, e.PhaseId, e.TaskId, d.LocId AS LocIdDtl, d.Descr, d.Units
			, d.GLDesc, d.AddnlDescr, d.TaxClass, i.InvoiceNum
			, t.InvcDate, t.GlPeriod AS FiscalPeriod, t.FiscalYear, i.Qty
			, CASE WHEN @PrintAllInBase = 1 THEN i.UnitCost ELSE i.UnitCostFgn END AS UnitCost
			, CASE WHEN @PrintAllInBase = 1 THEN i.ExtCost ELSE i.ExtCostFgn END AS ExtCost
			, t.Ten99InvoiceYN
			, 0 AS CurrTaxable
			, 0 AS CurrNonTaxable
			, 0 AS CurrSalesTax
			, 0 AS CurrFreight
			, 0 AS CurrMisc
			, 0 AS CurrDisc 
			, 0 AS CurPrepaid
			, 0 AS CurrTotal
			, COALESCE(d.LineSeq, d.EntryNum) AS GroupHeader0
			, t.CurrCheckNo, t.CurrCheckDate, t.CurrDueDate1, t.CurrDueDate2, t.CurrDueDate3
			, 0 AS CurrPmtAmt1
			, 0 AS CurrPmtAmt2
			, 0 AS CurrPmtAmt3, d.LottedYn, d.GLAcctAccrual
		FROM #tmpPurchases p INNER JOIN dbo.tblPoTransHeader h ON p.TransId = h.TransId
			INNER JOIN dbo.tblPoTransInvoiceTot t ON p.TransID = t.TransId AND p.InvoiceNum = t.InvcNum 
			INNER JOIN dbo.tblPoTransInvoice i ON  t.TransID = i.TransID AND t.InvcNum = i.InvoiceNum 
			INNER JOIN dbo.tblPoTransDetail d ON i.TransId = d.TransID AND i.EntryNum = d.EntryNum
			LEFT JOIN #TempProject e ON d.TransID = e.TransId AND d.EntryNum = e.EntryNum
		WHERE i.Status = 0
		UNION ALL
		SELECT 1 AS RecType, h.TransId, h.BatchId, h.VendorId, h.DistCode, h.TaxGrpID
			, 0 AS EntryNum, NULL AS GLAcct, NULL AS WIPAcct, NULL AS ItemId
			, 0 AS ItemType
			, NULL AS ProjID, NULL AS CustId, NULL AS PhaseId, NULL AS TaskId, NULL AS LocIdDtl, NULL AS Descr
			, NULL AS Units
			, NULL AS GLDesc, NULL AS AddnlDescr, 0 AS TaxClass, t.InvcNum AS InvoiceNum
			, NULL AS InvoiceDate, 0 AS FiscalPeriod, 0 AS FiscalYear, 0 AS Qty
			, 0 AS UnitCost
			, 0 AS ExtCost
			, t.Ten99InvoiceYN
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrTaxable ELSE t.CurrTaxableFgn END AS CurrTaxable
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrNonTaxable ELSE t.CurrNonTaxableFgn END AS CurrNonTaxable
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrSalesTax + t.CurrTaxAdjAmt ELSE t.CurrSalesTaxFgn + t.CurrTaxAdjAmtFgn 
				END AS CurrSalesTax
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrFreight ELSE t.CurrFreightFgn END AS CurrFreight
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrMisc ELSE t.CurrMiscFgn END AS CurrMisc
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrDisc ELSE t.CurrDiscFgn END AS CurrDisc 
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPrepaid ELSE t.CurrPrepaidFgn END AS CurPrepaid
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrTaxable + t.CurrNonTaxable + t.CurrFreight + t.CurrMisc + t.CurrSalesTax + t.CurrTaxAdjAmt 
				ELSE t.CurrTaxableFgn + t.CurrNonTaxableFgn + t.CurrFreightFgn + t.CurrMiscFgn + t.CurrSalesTaxFgn + t.CurrTaxAdjAmtFgn 
				END AS CurrTotal
			, NULL AS GroupHeader0
			, t.CurrCheckNo, t.CurrCheckDate, t.CurrDueDate1, t.CurrDueDate2, t.CurrDueDate3
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt1 ELSE t.CurrPmtAmt1Fgn END AS CurrPmtAmt1
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt2 ELSE t.CurrPmtAmt2Fgn END AS CurrPmtAmt2
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt3 ELSE t.CurrPmtAmt3Fgn END AS CurrPmtAmt3,
			0 AS LottedYn, NULL
		FROM #tmpPurchases p INNER JOIN dbo.tblPoTransHeader h ON p.TransId = h.TransId
			INNER JOIN dbo.tblPoTransInvoiceTot t ON p.TransID = t.TransId AND p.InvoiceNum = t.InvcNum
	END

	--todo JC
	SELECT d.*, v.Name FROM #tmpPurchaseDetail d INNER JOIN dbo.tblApVendor v ON d.VendorId = v.VendorId

	IF @PrintDetail = 1 
	BEGIN
		--lot
		SELECT r.TransId, r.EntryNum, r.LotNum, i.InvoiceNum, SUM(ir.Qty) AS Qty
			, SUM(CASE WHEN @PrintAllInBase = 1 THEN i.UnitCost ELSE i.UnitCostFgn END * ir.Qty) AS ExtCost
		FROM #tmpPurchases t INNER JOIN dbo.tblPoTransInvoice i ON t.TransId = i.TransId AND t.InvoiceNum = i.InvoiceNum
			INNER JOIN tblPoTransInvc_Rcpt ir ON i.InvoiceId = ir.InvoiceId 
			INNER JOIN tblPoTransLotRcpt r ON ir.ReceiptId = r.ReceiptId
		WHERE i.Status = 0 AND r.LotNum IS NOT NULL
		GROUP BY r.TransId, r.EntryNum, r.LotNum, i.InvoiceNum
		ORDER BY i.InvoiceNum, r.LotNum

		--ser
		SELECT s.TransId, s.EntryNum, s.LotNum, s.SerNum
			, CASE WHEN @PrintAllInBase = 1 THEN s.InvcUnitCost ELSE s.InvcUnitCostFgn END AS UnitCost
			, CASE WHEN @PrintAllInBase = 1 THEN s.RcptUnitCost ELSE s.RcptUnitCostFgn END AS RcptUnitCost
			, s.InvcNum, i.LottedYn 		
		FROM #tmpPurchases t INNER JOIN dbo.tblPoTransSer s ON t.TransId = s.TransId AND t.InvoiceNum = s.InvcNum 
			INNER JOIN dbo.tblPoTransDetail d ON s.TransId = d.TransId AND s.EntryNum = d.EntryNum
			INNER JOIN dbo.tblInItem i ON d.ItemId = i.ItemId 
		ORDER BY s.InvcNum, s.LotNum, s.SerNum
	END			

	IF @SortBy < 2 
	BEGIN
		--Trans ID Total
		SELECT h.TransId, h.BatchId, h.TransType, h.VendorId, t.InvcNum AS InvoiceNum, t.InvcDate AS InvoiceDate, t.GLPeriod AS FiscalPeriod, t.FiscalYear
			, CONVERT(nvarchar, t.GLPeriod) + '/' + CONVERT(nvarchar, t.FiscalYear) AS PdYr
			, t.Ten99InvoiceYN
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrTaxable ELSE t.CurrTaxableFgn END AS CurrTaxable
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrNonTaxable ELSE t.CurrNonTaxableFgn END AS CurrNonTaxable
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrSalesTax + t.CurrTaxAdjAmt 
				ELSE t.CurrSalesTaxFgn + t.CurrTaxAdjAmtFgn END AS CurrSalesTax
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrFreight ELSE t.CurrFreightFgn END AS CurrFreight
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrMisc ELSE t.CurrMiscFgn END AS CurrMisc
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrDisc ELSE t.CurrDiscFgn END AS CurrDisc
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPrepaid ELSE t.CurrPrepaidFgn END AS CurrPrepaid
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrTaxable + t.CurrNonTaxable + t.CurrSalesTax + t.CurrTaxAdjAmt + t.CurrFreight + t.CurrMisc 
				ELSE t.CurrTaxableFgn + t.CurrNonTaxableFgn + t.CurrSalesTaxFgn + t.CurrTaxAdjAmtFgn + t.CurrFreightFgn + t.CurrMiscFgn END AS CurrTotal
			, t.CurrCheckNo, t.CurrCheckDate, t.CurrDueDate1, t.CurrDueDate2, t.CurrDueDate3
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt1 ELSE t.CurrPmtAmt1Fgn END AS CurrPmtAmt1
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt2 ELSE t.CurrPmtAmt2Fgn END AS CurrPmtAmt2
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt3 ELSE t.CurrPmtAmt3Fgn END AS CurrPmtAmt3
			, t.Status, h.CurrencyID 
		FROM #tmpPurchases p 
			INNER JOIN dbo.tblPoTransHeader h ON p.TransId = h.TransId 
			INNER JOIN dbo.tblPoTransInvoiceTot t ON p.TransId = t.TransId AND p.InvoiceNum = t.InvcNum

		--Sort By Total
		SELECT h.TransId, h.BatchId, h.TransType, h.VendorId, t.InvcNum AS InvoiceNum, t.InvcDate AS InvoiceDate, t.GLPeriod AS FiscalPeriod, t.FiscalYear
			, CONVERT(nvarchar, t.GLPeriod) + '/' + CONVERT(nvarchar, t.FiscalYear) AS PdYr
			, t.Ten99InvoiceYN
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrTaxable ELSE t.CurrTaxableFgn END AS CurrTaxable
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrNonTaxable ELSE t.CurrNonTaxableFgn END AS CurrNonTaxable
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrSalesTax + t.CurrTaxAdjAmt 
				ELSE t.CurrSalesTaxFgn + t.CurrTaxAdjAmtFgn END AS CurrSalesTax
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrFreight ELSE t.CurrFreightFgn END AS CurrFreight
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrMisc ELSE t.CurrMiscFgn END AS CurrMisc
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrDisc ELSE t.CurrDiscFgn END AS CurrDisc
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPrepaid ELSE t.CurrPrepaidFgn END AS CurrPrepaid
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrTaxable + t.CurrNonTaxable + t.CurrSalesTax + t.CurrTaxAdjAmt + t.CurrFreight + t.CurrMisc 
				ELSE t.CurrTaxableFgn + t.CurrNonTaxableFgn + t.CurrSalesTaxFgn + t.CurrTaxAdjAmtFgn + t.CurrFreightFgn + t.CurrMiscFgn END AS CurrTotal
			, t.CurrCheckNo, t.CurrCheckDate, t.CurrDueDate1, t.CurrDueDate2, t.CurrDueDate3
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt1 ELSE t.CurrPmtAmt1Fgn END AS CurrPmtAmt1
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt2 ELSE t.CurrPmtAmt2Fgn END AS CurrPmtAmt2
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt3 ELSE t.CurrPmtAmt3Fgn END AS CurrPmtAmt3
			, t.Status, h.CurrencyID 
		FROM #tmpPurchases p 
			INNER JOIN dbo.tblPoTransHeader h ON p.TransId = h.TransId 
			INNER JOIN dbo.tblPoTransInvoiceTot t ON p.TransId = t.TransId AND p.InvoiceNum = t.InvcNum 

		--Grand Total
		SELECT SUM(CurrTaxable) AS CurrTaxable
		, SUM(CurrNonTaxable) AS CurrNonTaxable
		, SUM(CurrSalesTax) AS CurrSalesTax
		, SUM(CurrFreight) AS CurrFreight
		, SUM(CurrMisc) AS CurrMisc
		, SUM(CurrDisc) AS  CurrDisc
		, SUM(CurrPrepaid) AS CurrPrepaid
		, SUM(CurrTotal) AS CurrTotal
		FROM (SELECT h.TransId, h.BatchId, h.TransType, h.VendorId, t.InvcNum AS InvoiceNum, t.InvcDate AS InvoiceDate, t.GLPeriod AS FiscalPeriod, t.FiscalYear
			, CONVERT(nvarchar, t.GLPeriod) + '/' + CONVERT(nvarchar, t.FiscalYear) AS PdYr
			, t.Ten99InvoiceYN
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrTaxable ELSE t.CurrTaxableFgn END AS CurrTaxable
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrNonTaxable ELSE t.CurrNonTaxableFgn END AS CurrNonTaxable
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrSalesTax + t.CurrTaxAdjAmt 
				ELSE t.CurrSalesTaxFgn + t.CurrTaxAdjAmtFgn END AS CurrSalesTax
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrFreight ELSE t.CurrFreightFgn END AS CurrFreight
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrMisc ELSE t.CurrMiscFgn END AS CurrMisc
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrDisc ELSE t.CurrDiscFgn END AS CurrDisc
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPrepaid ELSE t.CurrPrepaidFgn END AS CurrPrepaid
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrTaxable + t.CurrNonTaxable + t.CurrSalesTax + t.CurrTaxAdjAmt + t.CurrFreight + t.CurrMisc 
				ELSE t.CurrTaxableFgn + t.CurrNonTaxableFgn + t.CurrSalesTaxFgn + t.CurrTaxAdjAmtFgn + t.CurrFreightFgn + t.CurrMiscFgn END AS CurrTotal
			, t.CurrCheckNo, t.CurrCheckDate, t.CurrDueDate1, t.CurrDueDate2, t.CurrDueDate3
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt1 ELSE t.CurrPmtAmt1Fgn END AS CurrPmtAmt1
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt2 ELSE t.CurrPmtAmt2Fgn END AS CurrPmtAmt2
			, CASE WHEN @PrintAllInBase = 1 THEN t.CurrPmtAmt3 ELSE t.CurrPmtAmt3Fgn END AS CurrPmtAmt3
			, t.Status, h.CurrencyID 
		FROM #tmpPurchases p 
			INNER JOIN dbo.tblPoTransHeader h ON p.TransId = h.TransId 
			INNER JOIN dbo.tblPoTransInvoiceTot t ON p.TransId = t.TransId AND p.InvoiceNum = t.InvcNum 
			) tmp
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransactionJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoTransactionJournal_proc';

