
CREATE PROCEDURE dbo.trav_PoReceiveInvoiceReport_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null,
@FiscalYearFrom smallint = 2009,
@FiscalYearThru smallint = 2009,
@FiscalPeriodFrom smallint = 1,
@FiscalPeriodThru smallint = 12,
@ReceiptInvoiceDateFrom datetime = NULL,
@ReceiptInvoiceDateThru datetime = NULL,
@ReceiptInvoiceNoFrom pInvoiceNum = NULL,
@ReceiptInvoiceNoThru pInvoiceNum = NULL,
@PrintReceipt bit = 1,
@PrintInvoice bit = 1,
@PrintUnposted bit = 1,
@PrintPosted bit = 1,
@SortBy tinyint = 0 --0, Transaction No; 1, Rcpt/Invc No; 2, Staus; 3, Type; 4, Year/GL Period; 5, Vendor ID
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpPoReceiptInvoiceRpt
	(
		TransId pTransID NOT NULL, 
		EntryNum int NOT NULL, 
		RcptInvcNum pInvoiceNum NOT NULL, 
		[Status] tinyint, 
		RcptInvcDate datetime NULL, 
		GlPeriod smallint NOT NULL, 
		FiscalYear smallint NOT NULL, 
		Qty pDecimal NOT NULL, 
		UnitCost pDecimal NOT NULL, 
		ExtCost pDecimal NOT NULL, 
		ExtCostRcpt pDecimal NOT NULL, 
		ExtCostInvc pDecimal NOT NULL, 
		TransOrReturn nvarchar (10) NOT NULL, 
		ReceiptOrInvoice pInvoiceNum NOT NULL, 
		TransType smallint NOT NULL
	)

	IF @PrintReceipt = 1
	BEGIN
		INSERT INTO #tmpPoReceiptInvoiceRpt (TransId, EntryNum, RcptInvcNum, [Status], RcptInvcDate, 
			GlPeriod, FiscalYear, Qty, UnitCost, ExtCost, ExtCostRcpt, 
			ExtCostInvc, TransOrReturn, ReceiptOrInvoice, TransType) 
		SELECT r.TransID, r.EntryNum, r.ReceiptNum AS RcptInvcNum, r.Status, r.ReceiptDate AS RcptInvcDate,
			r.GlPeriod, r.FiscalYear, r.Qty, r.UnitCost, r.ExtCost, r.ExtCost * SIGN(h.TransType) AS ExtCostRcpt, 
			0 AS ExtCostInvc, CASE WHEN (h.TransType >= 0) THEN '0_TRN' ELSE '9_RET' END AS TransOrReturn, 
			'0_RCPT' AS ReceiptOrInvoice, h.TransType 
		FROM #tmpTransDetailList t INNER JOIN
				(SELECT p.TransId,r.EntryNum,p.ReceiptNum,p.ReceiptDate,p.GlPeriod,p.FiscalYear,r.Status,
					SUM(r.QtyFilled) AS Qty,SUM(CASE WHEN @PrintAllInBase = 1 THEN r.ExtCost ELSE r.ExtCostFgn END)/SUM(r.QtyFilled) AS UnitCost,
					SUM(CASE WHEN @PrintAllInBase = 1 THEN r.ExtCost ELSE r.ExtCostFgn END) AS ExtCost
				FROM dbo.tblPoTransReceipt p INNER JOIN dbo.tblPoTransLotRcpt r ON p.TransId = r.TransId AND p.ReceiptNum = r.RcptNum  
				WHERE (@PrintPosted = 1 AND r.Status = 1) OR (@PrintUnposted = 1 AND r.Status = 0)
				GROUP BY p.TransId,r.EntryNum,p.ReceiptNum,p.ReceiptDate,p.GlPeriod,p.FiscalYear,r.Status) r 
					ON t.TransId = r.TransId AND t.EntryNum = r.EntryNum
			INNER JOIN dbo.tblPoTransHeader h ON t.TransId = h.TransId
		WHERE (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
	END

	IF @PrintInvoice = 1
	BEGIN
		INSERT INTO #tmpPoReceiptInvoiceRpt (TransId, EntryNum, RcptInvcNum, [Status], RcptInvcDate,
			GlPeriod, FiscalYear, Qty, UnitCost, ExtCost, ExtCostRcpt,
			ExtCostInvc, TransOrReturn, ReceiptOrInvoice, TransType) 
		SELECT i.TransID, i.EntryNum, i.InvoiceNum AS RcptInvcNum, i.Status, i.InvcDate AS RcptInvcDate,
			i.GlPeriod, i.FiscalYear, i.Qty, i.UnitCost, i.ExtCost, 0 AS ExtCostRcpt, 
			i.ExtCost * SIGN(h.TransType) AS ExtCostInvc, 
			CASE WHEN (h.TransType >= 0) THEN '0_TRN' ELSE '9_RET' END AS TransOrReturn, 
			'9_INVC' AS ReceiptOrInvoice, h.TransType 
		FROM #tmpTransDetailList t INNER JOIN
				(SELECT p.TransId,r.EntryNum,r.InvoiceNum,p.InvcDate,p.GlPeriod,p.FiscalYear,r.Status,
					SUM(r.Qty) AS Qty,SUM(CASE WHEN @PrintAllInBase = 1 THEN r.ExtCost ELSE r.ExtCostFgn END)/SUM(r.Qty) AS UnitCost,
					SUM(CASE WHEN @PrintAllInBase = 1 THEN r.ExtCost ELSE r.ExtCostFgn END) AS ExtCost
				FROM dbo.tblPoTransInvoiceTot p INNER JOIN dbo.tblPoTransInvoice r ON p.TransId = r.TransId AND p.InvcNum = r.InvoiceNum  
				WHERE (@PrintPosted = 1 AND r.Status = 1) OR (@PrintUnposted = 1 AND r.Status = 0)
				GROUP BY p.TransId,r.EntryNum,r.InvoiceNum,p.InvcDate,p.GlPeriod,p.FiscalYear,r.Status) i 
					ON t.TransId = i.TransId AND t.EntryNum = i.EntryNum
			INNER JOIN dbo.tblPoTransHeader h ON t.TransId = h.TransId
		WHERE (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) 
	END

	SELECT CASE @SortBy 
			WHEN 0 THEN CAST(r.TransId AS nvarchar) 
			WHEN 1 THEN CAST(r.RcptInvcNum AS nvarchar) 
			WHEN 2 THEN CAST(r.Status  AS nvarchar) 
			WHEN 3 THEN CAST(r.TransOrReturn + r.ReceiptOrInvoice AS nvarchar) 
			WHEN 4 THEN CAST(RIGHT('0000' + LTRIM(STR(r.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(r.GlPeriod)), 3) AS nvarchar) 
			WHEN 5 THEN CAST(h.VendorId AS nvarchar) END AS GrpId1, 
		CASE @SortBy 
			WHEN 0 THEN CAST(h.VendorId AS nvarchar) 
			WHEN 1 THEN CAST(r.TransId AS nvarchar) 
			WHEN 2 THEN CAST(r.TransId AS nvarchar) 
			WHEN 3 THEN CAST(r.TransId AS nvarchar) 
			WHEN 4 THEN CAST(r.TransId AS nvarchar) 
			WHEN 5 THEN CAST(r.TransId AS nvarchar) END AS GrpId2, 
		h.BatchId, v.[Name], h.VendorId, d.ItemId, d.LocId AS LocIdDtl, d.Descr, d.Units, 
		r.TransId, r.EntryNum, r.RcptInvcNum, r.Status, r.RcptInvcDate, r.GlPeriod, r.FiscalYear,
		r.Qty, r.UnitCost, r.ExtCost, r.ExtCostRcpt, r.ExtCostInvc, r.TransOrReturn, r.ReceiptOrInvoice, r.TransType 
	FROM dbo.tblPoTransHeader h INNER JOIN dbo.tblApVendor v ON h.VendorId = v.VendorID
		INNER JOIN tblPoTransDetail d ON h.TransId = d.TransId
		INNER JOIN #tmpPoReceiptInvoiceRpt r ON d.TransID = r.TransID AND d.EntryNum = r.EntryNum 
	WHERE r.FiscalYear * 1000 + r.GlPeriod BETWEEN @FiscalYearFrom * 1000 + @FiscalPeriodFrom AND @FiscalYearThru * 1000 + @FiscalPeriodThru 
		AND (@ReceiptInvoiceNoFrom IS NULL OR r.RcptInvcNum >= @ReceiptInvoiceNoFrom) 
		AND (@ReceiptInvoiceNoThru IS NULL OR r.RcptInvcNum <= @ReceiptInvoiceNoThru)
		AND (@ReceiptInvoiceDateFrom IS NULL OR r.RcptInvcDate >= @ReceiptInvoiceDateFrom) 
		AND (@ReceiptInvoiceDateThru IS NULL OR r.RcptInvcDate <= @ReceiptInvoiceDateThru)		
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoReceiveInvoiceReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoReceiveInvoiceReport_proc';

