CREATE VIEW [dbo].[ALP_lkpSmAlpItems_Service]
AS
SELECT
	[i].[ItemCode] AS [ItemId],
	[i].[Desc] AS [Descr],
	[i].[UnitCost],
	[i].[UnitPrice],
	[i].[TaxClass],
	[i].[AlpServiceType],
	[i].[AlpAcctCode] AS [AcctCode]
FROM  [dbo].[ALP_tblSmItem_View] AS [i]
WHERE [i].[AlpServiceType] = 0