
CREATE View [dbo].[Alp_lkpArAlpSiteRecJobCust]  
/* 20qryCustSelect */  
As  
SELECT top 100 percent CustId,  
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
WHERE (AlpInactive=0)  
ORDER BY [CustName] +   
  CASE   
   WHEN AlpFirstName is null THEN ''  
   ELSE ', ' + AlpFirstName  
  END