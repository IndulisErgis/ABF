
CREATE PROCEDURE [dbo].[trav_ArRecurEntryList_proc]

@RptCurr pCurrency = 'USD'

AS
BEGIN TRY

	SELECT 0 AS RecType, h.RecurId, h.RunCode, h.RecurType, h.StartingDate, h.CustId, h.ShipToId
		, h.TaxableYn, h.PoDate, h.Rep1Id, h.Rep2Id
		, h.CustPoNum, h.EndingDate
		, d.EntryNum, d.[Descr] AS [Description], d.AddnlDescr AS AdditionalDescription
		, d.GlAcctSales, d.GlAcctCogs, d.GlAcctInv
		, d.Quantity, d.Units, t.[Desc] AS TermsDescription
		, 0 AS TaxSubtotal, 0 AS NontaxSubtotal, 0 AS Freight, 0 AS Misc, 0 AS SalesTax
		, 0 AS InvoiceTotal
		, d.UnitPrice, d.UnitCost
		, CAST(d.UnitPrice * Quantity AS float) AS ExtPrice
		, CAST(d.UnitCost * Quantity AS float) AS ExtCost
		, h.BillType, h.BillInterval, h.NextBillDate, h.LastBillDate, c.CustName 
		, h.PmtMethodId, p.PmtType
		, h.CcNum, h.CcHolder, h.CcExpire, h.BankName, h.BankAcctNum, h.BankRoutingCode, h.CCAuth
	FROM dbo.tblArRecurHeader h 
		LEFT JOIN dbo.tblArTermsCode t ON h.TermsCode = t.TermsCode 
		LEFT JOIN dbo.tblArRecurDetail d ON h.RecurId = d.RecurId 
		LEFT JOIN dbo.tblArCust c ON h.CustId = c.CustId 
		INNER JOIN #tmpRecuringEntry r ON h.RecurId = r.RecurId
		LEFT JOIN dbo.tblArPmtMethod p on h.PmtMethodId = p.PmtMethodId
	WHERE h.CurrencyID = @RptCurr

	UNION ALL

	SELECT 1 AS RecType, h.RecurId, h.RunCode, h.RecurType, h.StartingDate, h.CustId, h.ShipToId
		, h.TaxableYn, h.PoDate, h.Rep1Id, h.Rep2Id
		, h.CustPoNum, h.EndingDate
		, 0 AS EntryNum, '' AS [Description], '' AS AdditionalDescription
		, NULL AS GlAcctSales, NULL AS GlAcctCogs, NULL AS GlAcctInv
		, 0 AS QtyOrdSell, NULL AS UnitsSell, '' AS TermsDescription
		, 0 AS TaxSubtotal, 0 AS NontaxSubtotal, h.Freight, h.Misc, 0 AS SalesTax
		, 0 AS InvoiceTotal
		, 0 AS UnitPriceSell, 0 AS UnitCostSell
		, 0 AS ExtPrice
		, 0 AS ExtCost
		, h.BillType, h.BillInterval, h.NextBillDate, h.LastBillDate, '' AS CustName 
		, h.PmtMethodId, 1 AS PmtType
		, h.CcNum, h.CcHolder, h.CcExpire, h.BankName, h.BankAcctNum, h.BankRoutingCode, h.CCAuth
	FROM dbo.tblArRecurHeader h 
		INNER JOIN #tmpRecuringEntry r ON h.RecurId = r.RecurId
	WHERE h.CurrencyID = @RptCurr

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArRecurEntryList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArRecurEntryList_proc';

