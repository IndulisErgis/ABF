    
CREATE VIEW [dbo].[ALP_qryJmRevAllocRpt_Other_view]            
AS            
SELECT        
T.BranchId,        
'0' as GLAcct,        
'<N/A>' as GLAcctDescr,            
T.TicketId,        
T.SiteId,        
S.SiteName,        
TypeDetail = CASE WHEN ITEM.ItemType = 3 THEN 'Other Misc' ELSE 'Other Part' END,    
PartsPrice = 0,    
LaborPrice = 0,     
OtherPrice = isNull(STI.UnitPrice,0)*isNull(qtyAdded,0),    
OtherPriceParts = CASE WHEN ITEM.ItemType = 3     
      THEN 0        
      ELSE isNull(STI.UnitPrice,0)*isNull(qtyAdded,0) END,      
OtherPriceLabor = CASE WHEN ITEM.ItemType = 3     
      THEN isNull(STI.UnitPrice,0)*isNull(qtyAdded,0)     
      ELSE 0 END,      
SalesTax = 0,    
TotalBilled = 0,    
T.InvcNum,    
T.BilledYn,  
T.CompleteDate,           
T.CloseDate,        
T.OrderDate,        
STI.ItemId,        
STI.WhseId,                 
T.WorkCodeId,        
T.LseYn,        
T.DivId,        
T.DeptId,          
ALP_tblArAlpBranch.Branch   
,D.GLSegId AS DivGLSegId ,D.Name --Added by NSK on 10 Jan 2017.  
FROM   dbo.ALP_tblJmSvcTkt T INNER JOIN dbo.ALP_tblJMSvcTktItem STI ON T.TicketId = STI.TicketId         
  INNER JOIN dbo.ALP_tblArAlpSite S ON T.SiteId = S.SiteId     
  INNER JOIN ALP_tblArAlpBranch ON T.BranchId = ALP_tblArAlpBranch.BranchId    
  LEFT OUTER JOIN dbo.tblInItem AS ITEM ON STI.ItemId = ITEM.ItemId         
  LEFT OUTER JOIN dbo.ALP_tblJmResolution AS Reso ON STI.ResolutionId =  Reso.ResolutionId  
  LEFT OUTER JOIN ALP_tblArAlpDivision D ON D.DivisionId=T.DivId --Added by NSK on 10 Jan 2017.        
WHERE  T.CompleteDate is not null     
AND TreatAsPartYn = 0    
AND STI.KittedYN = 0     
AND STI.AlpVendorKitComponentYn = 0        
AND (Reso.Action='Add' or Reso.Action='Replace')  
AND (isNull(STI.UnitPrice,0)*isNull(qtyAdded,0) <> 0 )