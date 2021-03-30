
CREATE function [dbo].[ALP_ufxSISite_FindByCustId]   
(    
 @CustId VARCHAR(10)    
)    
RETURNS @Sites TABLE    
 ( [SiteId] INT NOT NULL PRIMARY KEY,    
  [SiteSys] BIT NOT NULL DEFAULT(0),    
  [SiteRecBill] BIT NOT NULL DEFAULT(0),    
  [SiteRecJob] BIT NOT NULL DEFAULT(0)    
 )    
AS   
  --MAH 01/27/14:  modified to ignore recbills having expired or cancelled services     
BEGIN     
 INSERT INTO @Sites    
 ([SiteId], [SiteSys])    
 SELECT DISTINCT    
  [SiteId],    
  CAST(1 AS BIT)    
 FROM [dbo].[ALP_tblArAlpSiteSys] AS [ss] WITH (NOLOCK)    
 WHERE [ss].[PulledDate] IS NULL    
  AND [ss].[CustId] = @CustId    
  AND [ss].[SiteId] IS NOT NULL
    
  --MAH 01/27/14:  modified to ignore recbills having expired or cancelled services    
 MERGE @Sites AS [target]    
 USING (    
  SELECT DISTINCT    
   [srb].[SiteId]   
  FROM [dbo].[ALP_tblArAlpSiteRecBill] AS [srb]   
 INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServ] AS [srbs] WITH (NOLOCK)  
 ON [srb].RecBillID = [srbs].RecBillID     
  WHERE [srb].[CustId] = @CustId  
 AND ([srbs].[Status] <> 'Expired')   
 AND ([srbs].[Status] <> 'Cancelled')  
  ) AS [source] ([SiteId])    
  ON [target].[SiteId] = [source].[SiteId]    
 WHEN MATCHED    
  THEN UPDATE SET [SiteRecBill] = 1    
 WHEN NOT MATCHED BY TARGET    
  THEN INSERT ([SiteId], [SiteRecBill]) VALUES([SiteId], 1);     
 --MERGE @Sites AS [target]    
 --USING (    
 -- SELECT DISTINCT    
 --  [srb].[SiteId]    
 -- FROM [dbo].[ALP_tblArAlpSiteRecBill] AS [srb] WITH (NOLOCK)    
 -- WHERE [srb].[CustId] = @CustId   
 -- ) AS [source] ([SiteId])    
 -- ON [target].[SiteId] = [source].[SiteId]    
 --WHEN MATCHED    
 -- THEN UPDATE SET [SiteRecBill] = 1    
 --WHEN NOT MATCHED BY TARGET    
 -- THEN INSERT ([SiteId], [SiteRecBill]) VALUES([SiteId], 1);    
      
 MERGE @Sites as [target]    
 USING (    
  SELECT DISTINCT    
   [srj].[SiteId]    
  FROM [dbo].[ALP_tblArAlpSiteRecJob] AS [srj] WITH (NOLOCK)    
  WHERE [srj].[CustId] = @CustId 
	AND [srj].[SiteId] IS NOT NULL   
   AND ([srj].[ExpirationDate] IS NULL OR [srj].[ExpirationDate] > GETDATE())    
 ) AS [source] ([SiteId])    
  ON [target].[SiteId] = [source].[SiteId]    
 WHEN MATCHED THEN UPDATE SET [SiteRecJob] = 1    
 WHEN NOT MATCHED BY TARGET THEN INSERT ([SiteId], [SiteRecJob]) VALUES ([SiteId], 1);    
     
 RETURN    
END