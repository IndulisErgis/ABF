  
        
CREATE PROCEDURE [dbo].[ALP_IV_SiteView_proc]         
 (@Where nvarchar(1000)= NULL)      
 --created by mah 3/31/2016      
AS          
SET NOCOUNT ON;        
DECLARE @str nvarchar(2000) = NULL          
        
BEGIN TRY          
 CREATE TABLE #temp (        
  [SiteId] [int] NULL,        
  [Status] [varchar](10) NULL,        
  [SalesRepId] [varchar](3) NULL,        
  [BranchId] [int]  NULL,    
  [SiteName] [varchar] (80) NULL  
  ,[SiteFirstName]  [varchar] (30) NULL  
  ,[Phone]  [varchar] (15) NULL  
  ,[Addr1]  [varchar] (40) NULL  
  ,[Addr2]  [varchar] (60) NULL  
  ,[City]  [varchar] (30) NULL  
  ,[Region]   [varchar] (50) NULL  
  ,[PostalCode]  [varchar] (10) NULL  
  ,[County]  [varchar] (50) NULL  
  ,[Taxable] [bit] NULL  
  ,[TaxLocId] [varchar] (10) NULL  
  ,[SiteMemo] [text] NULL  
  ,[AlarmId] [varchar] (50) NULL  
  ,[SysId] int NULL  
  ,[SysDesc] [varchar] (255)  NULL  
  ,[CustId] [varchar] (10) NULL  --SysTypeId,  SysDesc  
  ,[LeaseYN] [bit] NULL
  ,[Panel] varchar(255) NULL	--Panel description
  ,[WarrExpires] Date NULL		
  ,[RemoveYn] bit NULL
  ,[PanelYn] bit NULL
  ,[WarrStarts] Date NULL
  ,[SysInstall] Date NULL
  ,[PulledDate] Date NULL
  ,[RepPlanId] int NULL
  ,[ContractId] int NULL
   )           
         
 SET @str =          
  'INSERT INTO #temp (SiteId,Status, SalesRepId, BranchId,SiteName  
  ,SiteFirstName ,Phone,Addr1  ,Addr2  ,City  ,Region  ,PostalCode  
  ,County  ,Taxable  ,TaxLocId  ,SiteMemo  ,AlarmId  ,SysId, SysDesc, CustId, LeaseYN, 
  Panel, WarrExpires, RemoveYn, PanelYn, WarrStarts, SysInstall, PulledDate, RepPlanId, ContractId)        
  SELECT  ALP_tblArAlpSite.SiteId, Status, SalesRepId1, BranchId, SiteName  
  ,AlpFirstName ,ALP_tblArAlpSite.Phone, ALP_tblArAlpSite.Addr1  ,ALP_tblArAlpSite.Addr2  ,ALP_tblArAlpSite.City  ,  
  ALP_tblArAlpSite.Region  ,ALP_tblArAlpSite.PostalCode  
  ,County,Taxable,TaxLocId,SiteMemo,ALP_tblArAlpSiteSys.AlarmId,  
  ALP_tblArAlpSiteSys.SysId, ALP_tblArAlpSiteSys.SysDesc , ALP_tblArAlpSiteSys.CustId ,ALP_tblArAlpSiteSys.LeaseYN,
  ALP_tblArAlpSiteSysItem.[Desc], CAST(ALP_tblArAlpSiteSysItem.WarrExpires as Date ),
  ALP_tblArAlpSiteSysItem.RemoveYn, ALP_tblArAlpSiteSysItem.PanelYn, CAST(ALP_tblArAlpSiteSysItem.WarrStarts as Date ),
  CAST (ALP_tblArAlpSiteSys.InstallDate  as Date ), CAST (ALP_tblArAlpSiteSys.PulledDate  as Date ),
  ALP_tblArAlpSiteSys.RepPlanId, ALP_tblArAlpSiteSys.ContractId
  FROM dbo.ALP_tblArAlpSite   
     LEFT OUTER JOIN ALP_tblArAlpSiteSys ON ALP_tblArAlpSite.SiteId = ALP_tblArAlpSiteSys.SiteId 
     LEFT OUTER JOIN ALP_tblArAlpSiteSysItem ON ALP_tblArAlpSiteSysItem.SysId = ALP_tblArAlpSiteSys.SysId 
     '        
  + CASE WHEN @Where IS NULL THEN ' '        
   WHEN @Where = '' THEN ' '        
   WHEN @Where = ' ' THEN ' '        
   ELSE ' WHERE ' + @Where        
   END         
        
 execute (@str)        
    
 SELECT T.SiteId, T.Status, T.SalesRepId as Rep,        
  T.SiteName, T.SiteFirstName, T.Phone,T.Addr1, T.Addr2, T.City,T.Region, T.PostalCode as Zip,   
  T.County  ,CASE WHEN T.Taxable = 1 THEN 'Y' ELSE 'N' END AS Taxable ,T.TaxLocId  ,T.SiteMemo  ,T.AlarmId  ,T.SysDesc as System,          
  ALP_tblArAlpBranch.Branch,  T.CustId,C.CustName , CASE WHEN T.LeaseYN = 1 THEN 'Y' ELSE 'N' END AS Leased, T.Panel, 
  T.WarrExpires, T.WarrStarts, T.SysInstall, T.PulledDate , ALP_tblArAlpRepairPlan.RepPlan, ALP_tblArAlpCustContract.ContractNum as SysContract
  FROM #temp T LEFT OUTER JOIN tblArCust C ON T.CustId = C.CustId  
  LEFT OUTER JOIN ALP_tblArAlpBranch ON T.BranchId = ALP_tblArAlpBranch.BranchId 
  LEFT OUTER JOIN ALP_tblArAlpRepairPlan ON ALP_tblArAlpRepairPlan.RepPlanId = T.RepPlanId 
  LEFT OUTER JOIN ALP_tblArAlpCustContract ON ALP_tblArAlpCustContract.ContractId = T.ContractId
  where T.PanelYn = 1 and T.RemoveYn = 0   
   
 DROP TABLE #temp           
END TRY          
BEGIN CATCH          
 EXEC dbo.trav_RaiseError_proc          
END CATCH