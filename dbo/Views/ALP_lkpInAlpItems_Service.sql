CREATE VIEW [dbo].[ALP_lkpInAlpItems_Service]
AS
SELECT
	[i].[ItemId],
	[i].[Descr],
	[i].[SalesCat],
	[i].[TaxClass],
	[i].[ItemType],
	[i].[AlpServiceType],
	[i].[AlpAcctCode] AS [AcctCode]
FROM [dbo].[ALP_tblInItem_View] AS [i]
WHERE	[i].[ItemType] = 3
	AND [i].[AlpServiceType] = 0