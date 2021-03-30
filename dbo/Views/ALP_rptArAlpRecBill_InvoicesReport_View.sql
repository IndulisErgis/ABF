CREATE VIEW [dbo].[ALP_rptArAlpRecBill_InvoicesReport_View]
AS
	SELECT
		[th].[TransId],
		[td].[EntryNum],
		[th].[CustId], 
		[th].[TaxableYN], 
		[th].[InvcNum], 
		[th].[TaxSubtotalFgn], 
		[th].[NonTaxSubtotalFgn], 
		[th].[SalesTaxFgn], 
		[th].[SourceId], 
		[s].[SiteID], 
		[th].[AlpRecBillRef],
		[s].[SiteName] +  
        CASE 
			WHEN [s].[AlpFirstName] IS NULL THEN '' 
			ELSE ', ' + [s].[AlpFirstName]
		END AS [Name],
		[td].[PartId],
		[td].[Desc],
		[td].[AddnlDesc],
		[td].[UnitPriceSellFgn],
		[td].[QtyShipSell],
		[r].[RunId],
		[td].[LineSeq]
	FROM [dbo].[ALP_tblArAlpRecBillRun] AS [r]
	INNER JOIN [ALP_tblArTransHeader_view] AS [th]
		ON	[th].[SourceId] = [r].[RunGuid]
	INNER JOIN [ALP_tblArAlpSite_view] AS [s]
		ON	[s].[SiteId] = [th].[AlpSiteID]
	INNER JOIN [ALP_tblArTransDetail_view] AS [td]
		ON	[td].[TransID] = [th].[TransId]