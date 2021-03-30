CREATE VIEW [dbo].[ALP_lkpArAlpSiteRecBillServId_IN]  
AS  
SELECT  
 [i].[ItemId],  
 [i].[Descr],  
 [s].[ServiceTypeId],  
 [i].[AlpAcctCode],  
 [i].[ItemType],  
 [i].[TaxClass]  ,[i].ItemId as ServiceId
FROM [dbo].[ALP_tblInItem_View] AS [i]  
INNER JOIN [dbo].[ALP_tblArAlpServiceType] AS [s]  
 ON [s].[ServiceTypeId] = [i].[AlpServiceType]  
WHERE [s].[RecurringSvc] = 1 -- recurring item  
 AND [i].[ItemType] = 3 -- Service