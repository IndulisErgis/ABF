
CREATE Procedure dbo.Alp_lkpArAlpSiteRecJobCust_sp    
/* 20qryCustSelect */
As    
set nocount on    
SELECT CustId,    
 Cust =  [CustName] +     
  CASE     
   WHEN AlpFirstName is null THEN ''    
   ELSE ', ' + AlpFirstName    
  END    
  + Char(13) + Char(10)    
  + COALESCE([addr1],'') + ' '    
  + COALESCE([addr2],'') + Char(13) + Char(10)    
  + COALESCE([city],'')  + ', '     
  + COALESCE([region],'') + ' '     
  + COALESCE([postalcode],'') ,     
 AlpInactive,     
 Address = COALESCE([addr1],'') + ' '    
  + COALESCE([addr2],'') + Char(13) + Char(10)    
  + COALESCE([city],'')  + ', '     
  + COALESCE([region],'') + ' '     
  + COALESCE([postalcode],'')      
FROM ALP_tblArCust_view    
WHERE  [Status] = 0 --(AlpInactive=0) OR (AlpInactive IS NULL) 
ORDER BY CustId
-- [CustName] +     
--  CASE     
--   WHEN AlpFirstName is null THEN ''    
--   ELSE ', ' + AlpFirstName    
--  END    
RETURN