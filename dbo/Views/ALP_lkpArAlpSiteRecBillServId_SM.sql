CREATE VIEW [dbo].[ALP_lkpArAlpSiteRecBillServId_SM]
AS
SELECT
[i].[ItemCode] as [ItemId],
[i].[Desc] as [Descr],
[i].[UnitCost],
[i].[UnitPrice],
[i].[TaxClass],
[i].[AlpAcctCode] ,
[s].[ServiceTypeId] ,[i].[ItemCode] as ServiceId
FROM [dbo].[ALP_tblSmItem_View] AS [i]
INNER JOIN [ALP_tblArAlpServiceType] AS [s]
ON [s].[ServiceTypeId] = [i].[AlpServiceType]
WHERE [s].[RecurringSvc] = 1