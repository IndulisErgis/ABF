
CREATE PROCEDURE dbo.trav_ArSummaryOpenInvoiceView_proc
@WksDate datetime = NULL

AS
BEGIN TRY
	SET NOCOUNT ON

	SELECT CustomerId, c.CustName AS CustomerName, InvoiceNumber, tmp.CurrencyId, SourceApp, NetDueDate
		, InvoiceDate, DiscountDueDate, ISNULL(Amount, 0) AS Amount, ISNULL(AmountFgn, 0) AS AmountFgn
		, ISNULL(CASE WHEN ((NetDueDate < @WksDate) AND (Amount > 0)) THEN Amount ELSE 0 END, 0) AS PastDueAmount
		, ISNULL(CASE WHEN ((NetDueDate < @WksDate) AND (AmountFgn > 0)) THEN AmountFgn ELSE 0 END, 0) AS PastDueAmountFgn
		, ISNULL(DiscountAllowed, 0) AS DiscountAllowed, ISNULL(DiscountAllowedFgn, 0) AS DiscountAllowedFgn
		, c.[Status] AS CustomerStatus, c.ClassId, c.GroupCode, c.AcctType, c.PriceCode
		, c.CreditLimit, c.TerrId, c.CustLevel 
	FROM 
		(
		SELECT i.CustId AS CustomerId, InvcNum AS InvoiceNumber, i.CurrencyId
			, ISNULL(MIN(CASE WHEN RecType > 0 THEN SourceApp ELSE NULL END), 0) AS SourceApp
			, MIN(CASE WHEN RecType > 0 THEN NetDueDate ELSE NULL END) AS NetDueDate
			, MIN(TransDate) InvoiceDate, MIN(DiscDueDate) DiscountDueDate
			, ISNULL(SUM(SIGN(RecType) * Amt), 0) AS Amount
			, ISNULL(SUM(SIGN(RecType) * AmtFgn), 0) AS AmountFgn
			, ISNULL(SUM(SIGN(RecType) * DiscAmt), 0) AS DiscountAllowed
			, ISNULL(SUM(SIGN(RecType) * DiscAmtFgn), 0) AS DiscountAllowedFgn 
		FROM dbo.tblArOpenInvoice i 
			INNER JOIN #tmpInvoiceList t ON i.[Counter] = t.[Counter] 
		GROUP BY i.CustId, InvcNum, i.CurrencyId
		) tmp 
	LEFT JOIN dbo.tblArCust c on tmp.CustomerId = c.CustId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArSummaryOpenInvoiceView_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArSummaryOpenInvoiceView_proc';

