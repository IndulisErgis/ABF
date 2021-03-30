CREATE VIEW [dbo].[ALP_lkpArAlpSiteSysIdByCS]  
AS  
SELECT  [ss].[SysId],  [st].[SysType],  [ss].[SysDesc],  
 [ss].[SiteId]  
FROM [dbo].[ALP_tblArAlpSiteSys] AS [ss]  
INNER JOIN [dbo].[ALP_tblArAlpSysType] AS [st]   
 ON [ss].[SysTypeId] = [st].[SysTypeId]  
--INNER JOIN [dbo].[ALP_tblArAlpCentralStation] AS [cs]  
-- ON [cs].[CentralId] = [ss].[CentralId]  
LEFT OUTER JOIN [dbo].[ALP_tblArAlpCustContract] AS [cc]  
 ON [ss].[ContractId] = [cc].[ContractId] 
 
 --Below code commented by ravi and mah on 12.07.2013
-- SELECT  [ss].[SysId],  [st].[SysType],  [ss].[SysDesc],  
-- [ss].[SiteId]  
--FROM [dbo].[ALP_tblArAlpSiteSys] AS [ss]  
--INNER JOIN [dbo].[ALP_tblArAlpSysType] AS [st]   
-- ON [ss].[SysTypeId] = [st].[SysTypeId]  
--INNER JOIN [dbo].[ALP_tblArAlpCentralStation] AS [cs]  
-- ON [cs].[CentralId] = [ss].[CentralId]  
--LEFT OUTER JOIN [dbo].[ALP_tblArAlpCustContract] AS [cc]  
-- ON [ss].[ContractId] = [cc].[ContractId]  