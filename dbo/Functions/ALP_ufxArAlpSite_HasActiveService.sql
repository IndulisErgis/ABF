CREATE FUNCTION [dbo].[ALP_ufxArAlpSite_HasActiveService]    
(    
 @SiteId INT    
)    
   
--MAH 02/13/14 - add condition to identify immediately expired and cancelled services,   
--  without having to wait for the next Recurring Billing run ( which automatically changes the status)  
RETURNS BIT    
AS    
BEGIN    
 DECLARE @Exists BIT    
 SET @Exists = 0    
 IF EXISTS(     
  SELECT 1    
  FROM [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]    
  INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS rb    
   ON [rb].[RecBillId] = [rbs].[RecBillId]    
   INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS p  
   ON rbs.RecBillServID = p.RecBillServID   
  WHERE [rb].[SiteId] = @SiteId    
   AND [rbs].[RecBillId] = [rb].[RecBillId]    
   AND [rbs].[ServiceStartDate] IS NOT NULL    
   --AND ([rbs].[ServiceStartDate] <= GetDate())    
   AND [rbs].[Status] IN ('Active', 'New')  
   --added 2/13/14:  
   AND ((p.EndBillDate is NULL) OR (p.EndBillDate > GetDate() ))   
 )    
 BEGIN    
  SET @Exists = 1    
 END    
 RETURN @Exists    
END