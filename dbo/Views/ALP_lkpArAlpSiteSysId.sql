CREATE VIEW [dbo].[ALP_lkpArAlpSiteSysId]
AS
SELECT	[ss].[SysId],	[st].[SysType],	[ss].[SysDesc],
	[ss].[SiteId]
FROM [dbo].[ALP_tblArAlpSiteSys] AS [ss]
INNER JOIN [dbo].[ALP_tblArAlpSysType] AS [st] 
	ON [ss].[SysTypeId] = [st].[SysTypeId]
LEFT OUTER JOIN [dbo].[ALP_tblArAlpCustContract] AS [cc]
	ON [ss].[ContractId] = [cc].[ContractId]