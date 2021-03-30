
Create View dbo.trav_ArOpenInvoiceSummary_view
AS
	SELECT CustId CustomerId, InvcNum InvoiceNumber, [Status], CurrencyId
		, Min(TransDate) InvoiceDate, Min(DiscDueDate) DiscountDueDate
		, isnull(Sum(Sign(RecType) * Amt), 0) AmountDue, isnull(Sum(Sign(RecType) * AmtFgn), 0) AmountDueFgn
		, isnull(Sum(Sign(RecType) * DiscAmt), 0) DiscountAllowed, isnull(Sum(Sign(RecType) * DiscAmtFgn), 0) DiscountAllowedFgn
	FROM dbo.tblArOpenInvoice WHERE [Status]<>4 and RecType <> 5 
	GROUP BY CustId, InvcNum, [Status], CurrencyId
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArOpenInvoiceSummary_view';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'VIEW', @level1name = N'trav_ArOpenInvoiceSummary_view';

