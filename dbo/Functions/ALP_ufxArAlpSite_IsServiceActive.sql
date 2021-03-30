CREATE FUNCTION [dbo].[ALP_ufxArAlpSite_IsServiceActive]      
(      
 @SiteId INT,
 @ServID INT,
 @AsOfDate Date      
)      
--created by MAH 6/23/16  
RETURNS BIT      
AS      
BEGIN      
 DECLARE @IsActive BIT      
 SET @IsActive = 0      
 IF EXISTS(       
  SELECT 1      
  FROM [dbo].[ALP_tblArAlpSiteRecBillServ] AS [rbs]      
  INNER JOIN [dbo].[ALP_tblArAlpSiteRecBill] AS rb      
   ON [rb].[RecBillId] = [rbs].[RecBillId]      
   INNER JOIN [dbo].[ALP_tblArAlpSiteRecBillServPrice] AS p    
   ON rbs.RecBillServID = p.RecBillServID     
  WHERE [rb].[SiteId] = @SiteId      
   AND [rbs].[RecBillId] = [rb].[RecBillId]
   AND [rbs].[RecBillServID] = @ServId      
   AND [rbs].[ServiceStartDate] IS NOT NULL      
   AND ([rbs].[ServiceStartDate] <= @AsOfDate )     
   --AND [rbs].[Status] IN ('Active', 'New')    
   AND ((p.EndBillDate is NULL) OR (p.EndBillDate >= @AsOfDate ))
   AND (([rbs].[CanServEndDate] is NULL) OR ( [rbs].[CanServEndDate] >= @AsOfDate ))    
 )      
 BEGIN      
  SET @IsActive = 1      
 END      
 RETURN @IsActive      
END