  
CREATE VIEW [dbo].[ALP_qryJmRevAllocRpt_Parts_view]            
AS            
SELECT        
T.BranchId,        
'0' as GLAcct,        
'<N/A>' as GLAcctDescr,            
T.TicketId,        
T.SiteId,        
S.SiteName,        
TypeDetail =  'Parts',    
PartsPrice = T.PartsPrice,    
LaborPrice = 0,     
OtherPrice = 0,   
OtherPriceParts = 0,     
OtherPriceLabor = 0,    
SalesTax = 0,    
TotalBilled = 0,    
T.InvcNum,    
T.BilledYn,    
T.CompleteDate,        
T.CloseDate,        
T.OrderDate,        
ItemId  =  T.PartsItemId,    
WhseId = ALP_tblArAlpBranch.DfltLocID,       
T.WorkCodeId,        
T.LseYn,        
T.DivId,        
T.DeptId,          
ALP_tblArAlpBranch.Branch   
,D.GLSegId AS DivGLSegId ,D.Name --Added by NSK on 10 Jan 2017. 
FROM   dbo.ALP_tblJmSvcTkt T       
  INNER JOIN dbo.ALP_tblArAlpSite S ON T.SiteId = S.SiteId     
  INNER JOIN ALP_tblArAlpBranch ON T.BranchId = ALP_tblArAlpBranch.BranchId    
  LEFT OUTER JOIN dbo.tblInItem AS ITEM ON T.PartsItemId = ITEM.ItemId  
  LEFT OUTER JOIN ALP_tblArAlpDivision D ON D.DivisionId=T.DivId --Added by NSK on 10 Jan 2017.            
WHERE  T.CompleteDate is not null     
 AND T.PartsPrice <> 0 --only select records that have non-zero parts price in the Billing tab.    