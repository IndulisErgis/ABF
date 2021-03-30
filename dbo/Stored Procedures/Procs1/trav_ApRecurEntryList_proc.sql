
CREATE PROCEDURE [dbo].[trav_ApRecurEntryList_proc]

@RptCurr pCurrency = 'USD'

AS
BEGIN TRY

	SELECT 0 AS RecType, h.RecurID, h.VendorID, h.InvoiceNum, h.PONum
		, h.RunCode, h.StartingDate, h.EndingDate, h.NumOfPmt, h.RemainingPmt
		, d.EntryNum, d.PartId, d.[Desc], d.GlAcct
		, d.Qty, d.Units, d.GlDesc, h.StartingBal, h.RemainingBal
		, 0 AS Subtotal, 0 AS Freight, 0 AS Misc, 0 AS SalesTax, 0 AS InvoiceTotal
		, d.UnitCost, d.ExtCost
		, h.BillType, h.BillInterval, h.NextBillDate, h.LastBillDate, v.[Name] 
	FROM dbo.tblApRecurHeader h 
		LEFT JOIN dbo.tblApRecurDetail d ON h.RecurID = d.RecurID 
		LEFT JOIN dbo.tblApVendor v ON h.VendorID = v.VendorID 
		INNER JOIN #tmpRecurEntry r ON h.RecurID = r.RecurId
	WHERE h.CurrencyID = @RptCurr

	UNION ALL

	SELECT 1 AS RecType, h.RecurID, h.VendorID, h.InvoiceNum, h.PONum
		, h.RunCode, h.StartingDate, h.EndingDate, h.NumOfPmt, h.RemainingPmt
		, 0 AS EntryNum, NULL AS PartId, NULL AS [Desc], NULL AS GlAcct
		, 0 AS Qty, NULL AS Units, NULL AS GlDesc, h.StartingBal, h.RemainingBal
		, h.Subtotal, h.Freight, h.Misc, h.SalesTax, h.Subtotal + h.Freight + h.Misc + h.SalesTax AS InvoiceTotal
		, 0 AS UnitCost, 0 AS ExtCost
		, h.BillType, h.BillInterval, h.NextBillDate, h.LastBillDate, NULL AS [Name] 
	FROM dbo.tblApRecurHeader h 
		INNER JOIN #tmpRecurEntry r ON h.RecurID = r.RecurId
	WHERE h.CurrencyID = @RptCurr

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApRecurEntryList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApRecurEntryList_proc';

