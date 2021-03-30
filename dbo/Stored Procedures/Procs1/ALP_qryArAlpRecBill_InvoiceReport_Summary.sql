
CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_InvoiceReport_Summary]
(
	@RunId INT
)
AS
BEGIN
	SELECT DISTINCT
		[i].[TransId],
		[i].[CustId],
		[i].[TaxableYN],
		[i].[InvcNum],
		[i].[TaxSubtotalFgn],
		[i].[NonTaxSubtotalFgn],
		[i].[SalesTaxFgn],
		[i].[SourceId],
		[i].[SiteID],
		[i].[AlpRecBillRef],
		[i].[Name],
		[i].[RunId]
	FROM [dbo].[ALP_rptArAlpRecBill_InvoicesReport_View] AS [i]
	WHERE	[i].[RunId] = @RunId
	ORDER BY [i].[TransId]
END