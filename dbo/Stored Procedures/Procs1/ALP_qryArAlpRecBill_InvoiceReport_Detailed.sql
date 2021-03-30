
CREATE  PROCEDURE [dbo].[ALP_qryArAlpRecBill_InvoiceReport_Detailed]
(
	@RunId INT
)
AS
BEGIN
	SELECT
		[i].[TransId], 
		[i].[EntryNum], 
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
		[i].[PartId], 
		[i].[Desc], 
		[i].[AddnlDesc], 
		[i].[UnitPriceSellFgn], 
		[i].[QtyShipSell], 
		[i].[RunId], 
		[i].[LineSeq]
	FROM [dbo].[ALP_rptArAlpRecBill_InvoicesReport_View] AS [i]
	WHERE	[i].[RunId] = @RunId
END