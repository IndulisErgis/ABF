CREATE VIEW [dbo].[ALP_qryJm600_Labor_view]   
--created 12/19/16 MAH - need to get the labor costs data from timecards             
AS              
SELECT   
T.BranchId,          
'0' as GLAcct,          
'<N/A>' as GLAcctDescr,              
T.TicketId,          
T.SiteId,          
S.SiteName,          
TypeDetail =  'Labor',     
PartsCost = 0,      
LaborCost = CONVERT(decimal(10,2),([EndTime]-[StartTime])/60.00 *[laborcostrate]),     
OtherCost = 0,      
OtherCostParts = 0,       
OtherCostLabor = 0,       
--SalesTax = 0,      
--TotalBilled = 0,      
--T.InvcNum,      
--T.BilledYn,      
T.CompleteDate,          
T.CloseDate,          
T.OrderDate,          
ItemId  =  T.LaborItemId,        
WhseId = ALP_tblArAlpBranch.DfltLocID,        
T.WorkCodeId,          
T.LseYn,          
T.DivId,          
T.DeptId,            
ALP_tblArAlpBranch.Branch      
,D.GLSegId AS DivGLSegId ,D.Name --Added by NSK on 10 Jan 2017. 
FROM   dbo.ALP_tblJmSvcTkt T       
  INNER JOIN dbo.ALP_tblArAlpSite S ON T.SiteId = S.SiteId       
  LEFT OUTER JOIN ALP_tblArAlpBranch ON T.BranchId = ALP_tblArAlpBranch.BranchId     
  LEFT OUTER JOIN dbo.tblInItem AS ITEM ON T.PartsItemId = ITEM.ItemId   
  LEFT OUTER JOIN  ALP_tblJmTimeCard  TC ON T.TicketId = TC.TicketId             
  LEFT OUTER JOIN  ALP_tblJmTimeCode CD ON TC.TimeCodeID = CD.TimeCodeID               
  LEFT OUTER JOIN ALP_tblArAlpDivision D ON D.DivisionId=T.DivId --Added by NSK on 10 Jan 2017.
WHERE  T.CompleteDate is not null