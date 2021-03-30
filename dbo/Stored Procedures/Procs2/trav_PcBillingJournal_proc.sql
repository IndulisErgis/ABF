
CREATE PROCEDURE dbo.trav_PcBillingJournal_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null,
@PrintDetail bit = 1,
@SortBy tinyint = 0, -- 0, Batch/Transaction Number; 1, Customer ID; 2, Invoice Number; 3 Fiscal Year/Fiscal Period/GL Account; 4, Project
@CurrPrec tinyint = 2
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpInvoice
	(
		TransId pTransID NOT NULL
	)

	INSERT INTO #tmpInvoice (TransId) 
	SELECT h.TransId 
	FROM #tmpCustomerList c INNER JOIN dbo.tblPcInvoiceHeader h ON c.CustId = h.CustId 
		INNER JOIN #tmpInvoiceList b ON h.TransId = b.TransId 
	WHERE (@PrintAllInBase = 1 OR h.CurrencyID = @ReportCurrency) 

	SELECT 0 AS RecType
	, CASE @SortBy 
		WHEN 0 THEN CAST(h.BatchId AS nvarchar) 
		WHEN 1 THEN CAST(h.CustId AS nvarchar) 
		WHEN 2 THEN CAST(ISNULL(h.InvcNum, '') AS nvarchar) 
		WHEN 3 THEN CAST(RIGHT('0000' + LTRIM(STR(h.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(h.FiscalPeriod)), 3) AS nvarchar) 
		WHEN 4 THEN CAST((ISNULL(p.ProjectName, '') + ISNULL(l.PhaseId, '') + ISNULL(l.TaskId, '')) AS nvarchar) END AS GrpId1
	, CASE @SortBy 
		WHEN 0 THEN CAST(h.BatchId AS nvarchar) 
		WHEN 1 THEN CAST(h.CustId AS nvarchar) 
		WHEN 2 THEN CAST(ISNULL(h.InvcNum, '') AS nvarchar) 
		WHEN 3 THEN CAST(CASE WHEN a.[Type] = 6 AND p.[Type] = 0 THEN a.GLAcctIncome WHEN a.[Type] = 6 AND p.[Type] = 1 THEN a.GLAcctFixedFeeBilling ELSE a.GLAcctWIP END AS nvarchar) 
		WHEN 4 THEN CAST((ISNULL(p.ProjectName, '') + ISNULL(l.PhaseId, '') + ISNULL(l.TaskId, '')) AS nvarchar) END AS GrpId2
	, h.BatchId, h.TransId, h.TransType, h.CustId, c.CustName, h.TermsCode, h.InvcNum, h.OrgInvcNum, h.CustPONum, h.OrderDate
	, h.InvcDate, h.Rep1Id, h.Rep2Id, h.FiscalPeriod AS GLPeriod, h.FiscalYear, h.TaxGrpID AS TaxLocId
	, 0 AS TaxSubtotal, 0 AS NonTaxSubtotal, 0 AS SalesTax, 0 AS DepositAmt, 0 AS InvTotal
	, d.EntryNum, d.LineSeq, a.ResourceId AS PartId, a.LocId AS WhseId, d.Descr AS [Desc], d.AddnlDesc, d.TaxClass
	, CASE WHEN a.[Type] = 6 AND p.[Type] = 0 THEN a.GLAcctIncome WHEN a.[Type] = 6 AND p.[Type] = 1 THEN a.GLAcctFixedFeeBilling ELSE a.GLAcctWIP END AS GLAcct, a.Uom AS UnitsSell, SIGN(h.TransType) * d.Qty AS Qty
	, CASE WHEN d.Qty = 0 THEN CASE WHEN @PrintAllInBase = 1 THEN d.ExtPrice ELSE ExtPriceFgn END ELSE CASE WHEN @PrintAllInBase = 1 THEN d.ExtPrice ELSE ExtPriceFgn END / d.Qty END AS UnitPriceSell
	, SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN d.ExtPrice ELSE ExtPriceFgn END AS ExtPrice
	, CASE WHEN d.Qty = 0 THEN CASE WHEN @PrintAllInBase = 1 THEN d.ExtCost ELSE ExtCostFgn END ELSE CASE WHEN @PrintAllInBase = 1 THEN d.ExtCost ELSE ExtCostFgn END / d.Qty END AS UnitCostSell
	, SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN d.ExtCost ELSE d.ExtCostFgn END AS ExtCost,
	p.ProjectName AS ProjectId, l.PhaseId, l.TaskId
	FROM dbo.tblArCust AS c INNER JOIN dbo.tblPcInvoiceHeader AS h ON c.CustId = h.CustId 
		INNER JOIN #tmpInvoice t ON h.TransId = t.TransId
		LEFT JOIN dbo.tblPcInvoiceDetail AS d ON h.TransId = d.TransID 
		LEFT JOIN dbo.tblPcActivity a ON d.ActivityId = a.Id 
		LEFT JOIN dbo.tblPcProjectDetail l ON a.ProjectDetailId = l.Id 
		LEFT JOIN dbo.tblPcProject p ON l.ProjectId = p.Id
	UNION ALL
	SELECT 1 AS RecType
	, CASE @SortBy 
		WHEN 0 THEN CAST(h.BatchId AS nvarchar) 
		WHEN 1 THEN CAST(h.CustId AS nvarchar) 
		WHEN 2 THEN CAST(ISNULL(h.InvcNum, '') AS nvarchar) 
		WHEN 3 THEN CAST(RIGHT('0000' + LTRIM(STR(h.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(h.FiscalPeriod)), 3) AS nvarchar) 
		WHEN 4 THEN CAST(NULL AS nvarchar) END AS GrpId1
	, CASE @SortBy 
		WHEN 0 THEN CAST(h.BatchId AS nvarchar) 
		WHEN 1 THEN CAST(h.CustId AS nvarchar) 
		WHEN 2 THEN CAST(ISNULL(h.InvcNum, '') AS nvarchar) 
		WHEN 3 THEN CAST(NULL AS nvarchar) 
		WHEN 4 THEN CAST(NULL AS nvarchar) END AS GrpId2
	, h.BatchId, h.TransId, h.TransType, h.CustId, NULL AS CustName, h.TermsCode, h.InvcNum, h.OrgInvcNum, h.CustPONum, h.OrderDate
	, h.InvcDate, h.Rep1Id, h.Rep2Id, h.FiscalPeriod AS GLPeriod, h.FiscalYear, h.TaxGrpID AS TaxLocId
	, SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN h.TaxSubtotal ELSE h.TaxSubtotalFgn END AS TaxSubtotal
	, SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN h.NonTaxSubtotal ELSE h.NonTaxSubtotalFgn END AS NonTaxSubtotal
	, SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN h.SalesTax + h.TaxAmtAdj ELSE h.SalesTaxFgn + h.TaxAmtAdjFgn END AS SalesTax
	, SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN ISNULL(pmt.DepositTotal, 0) ELSE ISNULL(pmt.DepositTotalFgn, 0) END AS DepositAmt
	, SIGN(h.TransType) * CASE WHEN @PrintAllInBase = 1 THEN TaxSubtotal + NonTaxSubtotal + SalesTax + TaxAmtAdj
		ELSE TaxSubtotalFgn + NonTaxSubtotalFgn + SalesTaxFgn + TaxAmtAdjFgn END AS InvTotal
	, 0 AS EntryNum, 0 AS LineSeq, NULL AS PartId, NULL AS WhseId, NULL AS [Desc], NULL AS AddnlDesc
	, 0 AS TaxClass, NULL AS GLAcct, NULL AS UnitsSell, 0 AS Qty, 0 AS UnitPriceSell, 0 AS ExtPrice, 0 AS UnitCostSell, 0 AS ExtCost,
	NULL AS ProjectId, NULL AS PhaseId, NULL AS TaskId
	FROM dbo.tblPcInvoiceHeader h 
	INNER JOIN #tmpInvoice t ON h.TransId = t.TransId
	LEFT JOIN (SELECT l.TransID
		, SUM(p.DepositAmtApply) DepositTotal
		, SUM(ROUND(p.DepositAmtApply * h.ExchRate,@CurrPrec)) DepositTotalFgn
		FROM #tmpInvoice l INNER JOIN dbo.tblPcInvoiceHeader h ON l.TransId = h.TransId 
			INNER JOIN dbo.tblPcInvoiceDeposit p ON h.TransId = p.TransId GROUP BY l.TransId) pmt ON h.TransId = pmt.TransId

	IF @PrintDetail = 1 
	BEGIN
		SELECT h.CurrencyId, CASE WHEN ISNULL(h.OrgInvcNum, '') = '' THEN h.InvcNum ELSE h.OrgInvcNum END AS InvcNum, 
			o.TransId AS InvcTransID, h.CustId, h.InvcDate AS PmtDate,
			(h.TaxSubtotal+h.NonTaxSubtotal+h.SalesTax) AS PmtAmt, 
			(h.TaxSubtotalFgn+h.NonTaxSubtotalFgn+h.SalesTaxFgn) PmtAmtFgn, 
			(h.TaxSubtotal+h.NonTaxSubtotal+h.SalesTax) - (-h.CalcGainLoss) AS InvcAmt , 
			h.OrgInvcExchRate AS InvcExchRate, -h.CalcGainLoss AS CalcGainLoss, h.ExchRate, h.BatchID --flip sign of CalcGainLoss to offset TransType of -1
		FROM #tmpInvoice t INNER JOIN dbo.tblPcInvoiceHeader h ON t.TransId = h.TransId
			INNER JOIN dbo.trav_ArOrgInvcInfo_view l ON h.CustId = l.CustId AND h.OrgInvcNum = l.InvcNum --limit to most current invoice
			INNER JOIN dbo.tblArOpenInvoice o ON l.Counter = o.Counter
		WHERE h.TransType = -1 AND h.CalcGainLoss <> 0 --credit memos
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PcBillingJournal_proc';

