CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_InvoiceReport_HeaderSums]
(
	@RunId INT
)
AS
BEGIN
	SELECT 
		COALESCE(SUM([th].[TaxSubtotalFgn]), 0) AS [TaxSum], 
		COALESCE(SUM([th].[NonTaxSubtotalFgn]), 0) AS [NonTaxSum],
		COALESCE(SUM([th].[SalesTaxFgn]), 0) AS [SalesTaxSum]
	FROM [dbo].[ALP_tblArAlpRecBillRun] AS [r]
	INNER JOIN [ALP_tblArTransHeader_view] AS [th]
		ON	[th].[SourceId] = [r].[RunGuid]
	WHERE	[r].[RunId] = @RunId
END