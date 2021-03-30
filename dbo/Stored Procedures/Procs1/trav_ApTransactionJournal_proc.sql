
CREATE PROCEDURE dbo.trav_ApTransactionJournal_proc
@PrintAllInBase bit = 1,
@ReportCurrency pCurrency = Null,
@PrintPurchasesJournal bit = 1,
@PrintDetail bit = 1,
@SortBy tinyint = 0 --0, Transaction; 1, Vendor ID; 2, Year/GL Pd/Account;3, Item ID;4,Batch Code;
AS
SET NOCOUNT ON
BEGIN TRY

	CREATE TABLE #tmpPurchases
	(
		TransId pTransID NOT NULL
	)

	INSERT INTO #tmpPurchases (TransId) 
	SELECT t.TransId 
	FROM #tmpTransactionList t INNER JOIN dbo.tblApTransHeader h ON t.TransId = h.TransId 
		INNER JOIN #tmpVendorList v ON h.VendorId = v.VendorId 
	WHERE (@PrintAllInBase = 1 OR h.CurrencyId = @ReportCurrency) AND 
		(h.TransType = CASE WHEN @PrintPurchasesJournal = 0 THEN -1 ELSE 1 END) 

	SELECT 0 AS RecType, 
		CASE @SortBy 
			WHEN 0 THEN h.TransId 
			WHEN 1 THEN h.VendorId 
			WHEN 2 THEN RIGHT('0000' + LTRIM(STR(h.FiscalYear)), 4) + RIGHT('000' + LTRIM(STR(h.GlPeriod)), 3) + ISNULL(d.GLAcct, '')
			WHEN 3 THEN d.PartId 
			WHEN 4 THEN h.BatchId END AS GrpId1, 
		CASE @SortBy 
			WHEN 0 THEN h.BatchId 
			WHEN 1 THEN h.TransId 
			WHEN 2 THEN h.TransId 
			WHEN 3 THEN h.TransId 
			WHEN 4 THEN h.TransId END AS GrpId2,
		h.TransId, h.BatchId, h.VendorId, h.InvoiceNum, h.InvoiceDate,
		h.PONum, h.DistCode, h.DueDate1, h.DueDate2, h.DueDate3,
		0 AS PmtAmt1, 0 AS PmtAmt2, 0 AS PmtAmt3, 0 AS Subtotal, 0 AS SalesTax,
		0 AS Freight, 0 AS Misc, 0 AS CashDisc, 0 AS PrepaidAmt,
		h.CheckNum, h.CheckDate, h.DiscDueDate, h.GLPeriod, h.FiscalYear,
		h.Ten99InvoiceYN, 0 AS TaxAdjAmt, v.Name, d.EntryNum,
		d.PartID, d.PartType, d.WhseId, d.[Desc], 
		d.GLAcct, 
		i.GLAcctWIP AS WIPAcct, --this is actual account that is used in posting for job cost project
		d.Qty, d.Units, 
		CASE WHEN @PrintAllInBase = 1 THEN d.UnitCost ELSE d.UnitCostFgn END AS UnitCost,
		CASE WHEN @PrintAllInBase = 1 THEN d.ExtCost ELSE d.ExtCostFgn END AS ExtCost,
		d.GLDesc, d.LottedYN, p.CustId AS CustomerID, p.ProjectName AS JobId, e.PhaseId, e.TaskId,
		CASE WHEN a.TransId IS NULL THEN 0 ELSE 1 END AS AllocationsYn 
	FROM dbo.tblApVendor v 
		INNER JOIN dbo.tblApTransHeader h ON v.VendorID = h.VendorId 
		INNER JOIN #tmpPurchases t ON h.TransId = t.TransId 
		LEFT JOIN dbo.tblApTransDetail d ON h.TransId = d.TransID 
		LEFT JOIN
		(	SELECT d.TransId, d.EntryNum
			FROM #tmpPurchases t INNER JOIN dbo.tblApTransAlloc h ON t.TransId = h.TransId 
			INNER JOIN dbo.tblApTransAllocDtl d ON h.TransId = d.TransId AND h.EntryNum = d.EntryNum 
			GROUP BY d.TransId, d.EntryNum
		) a ON d.TransId = a.TransId AND d.EntryNum = a.EntryNum 
		LEFT JOIN dbo.tblApTransPc j ON h.TransId = j.TransId AND d.EntryNum = j.EntryNum 
		LEFT JOIN dbo.tblPcProjectDetail e ON j.ProjectDetailId = e.Id 
		LEFT JOIN dbo.tblPcProject p ON e.ProjectId = p.Id 
		LEFT JOIN dbo.tblPcActivity i ON j.ActivityId = i.Id 
	UNION ALL
	SELECT 1 AS RecType, 
		CASE @SortBy 
			WHEN 0 THEN h.TransId 
			WHEN 1 THEN h.VendorId 
			WHEN 2 THEN NULL
			WHEN 3 THEN NULL 
			WHEN 4 THEN h.BatchId END AS GrpId1, 
		CASE @SortBy 
			WHEN 0 THEN h.BatchId 
			WHEN 1 THEN h.TransId 
			WHEN 2 THEN h.TransId 
			WHEN 3 THEN h.TransId 
			WHEN 4 THEN h.TransId END AS GrpId2,
		h.TransId, h.BatchId, h.VendorId, h.InvoiceNum, h.InvoiceDate,
		h.PONum, h.DistCode, h.DueDate1, h.DueDate2, h.DueDate3,
		CASE WHEN @PrintAllInBase = 1 THEN h.PmtAmt1 ELSE h.PmtAmt1Fgn END AS PmtAmt1,
		CASE WHEN @PrintAllInBase = 1 THEN h.PmtAmt2 ELSE h.PmtAmt2Fgn END AS PmtAmt2,
		CASE WHEN @PrintAllInBase = 1 THEN h.PmtAmt3 ELSE h.PmtAmt3Fgn END AS PmtAmt3,
		CASE WHEN @PrintAllInBase = 1 THEN h.Subtotal ELSE h.SubtotalFgn END AS Subtotal,
		CASE WHEN @PrintAllInBase = 1 THEN h.SalesTax ELSE h.SalesTaxFgn END AS SalesTax,
		CASE WHEN @PrintAllInBase = 1 THEN h.Freight ELSE h.FreightFgn END AS Freight,
		CASE WHEN @PrintAllInBase = 1 THEN h.Misc ELSE h.MiscFgn END AS Misc,
		CASE WHEN @PrintAllInBase = 1 THEN h.CashDisc ELSE h.CashDiscFgn END AS CashDisc,
		CASE WHEN @PrintAllInBase = 1 THEN h.PrepaidAmt ELSE h.PrepaidAmtFgn END AS PrepaidAmt,
		h.CheckNum, h.CheckDate, h.DiscDueDate, h.GLPeriod, h.FiscalYear, h.Ten99InvoiceYN,
		CASE WHEN @PrintAllInBase = 1 THEN h.TaxAdjAmt ELSE h.TaxAdjAmtFgn END AS TaxAdjAmt,
		NULL AS [Name], 0 AS EntryNum, NULL AS PartID, 0 AS PartType, NULL AS WhseId,
		NULL AS [Desc], NULL AS GLAcct, NULL AS WipAcct, 0 AS Qty, NULL AS Units,
		0 AS UnitCost, 0 AS ExtCost, NULL AS GLDesc, 0 AS LottedYN,
		NULL AS CustomerID, NULL AS JobId, NULL AS PhaseId, NULL AS TaskId, 0 AS AllocationsYn 
	FROM dbo.tblApTransHeader h 
		INNER JOIN #tmpPurchases t ON h.TransId = t.TransId

	IF @PrintDetail = 1 
	BEGIN
		SELECT h.TransId, h.EntryNum, AcctId, 
			CASE WHEN @PrintAllInBase = 1 THEN Amount ELSE AmountFgn END AS Amount 
		FROM #tmpPurchases t INNER JOIN dbo.tblApTransAlloc h ON t.TransId = h.TransId 
			INNER JOIN dbo.tblApTransAllocDtl d ON h.TransId = d.TransId AND h.EntryNum = d.EntryNum 
		ORDER BY AcctId

		--lot
		SELECT l.TransId, l.EntryNum, l.LotNum, l.QtyFilled, 
			CASE WHEN @PrintAllInBase = 1 THEN l.CostUnit ELSE l.CostUnitFgn END AS CostUnit
		FROM #tmpPurchases t INNER JOIN dbo.tblApTransLot l ON t.TransId = l.TransId

		--ser
		SELECT s.TransId, s.EntryNum, s.LotNum, s.SerNum, 
			CASE WHEN @PrintAllInBase = 1 THEN s.CostUnit ELSE s.CostUnitFgn END AS CostUnit
		FROM #tmpPurchases t INNER JOIN dbo.tblApTransSer s ON t.TransId = s.TransId
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransactionJournal_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApTransactionJournal_proc';

