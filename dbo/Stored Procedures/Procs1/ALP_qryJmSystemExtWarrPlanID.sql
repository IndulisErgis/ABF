CREATE Procedure [dbo].[ALP_qryJmSystemExtWarrPlanID]      
/*Get the Extended Warr Plan Id */      
/* used in JM AlpLib function: GetDfltRepairPlan  */      
 (      
  @Sysid int = null,      
  @ItemDate datetime = null      
 )      
As      
set nocount on      
--04/22/15 MAH - changed to ensure selection of information only from     
--    Services billed to same customer as system's customer    
 SELECT ExtRepPlanId      
 FROM ALP_tblArAlpSiteRecBillServ RBS     
  INNER JOIN  ALP_tblArAlpSiteRecBill RB ON RBS.RecBillId = RB.RecBillId    
  INNER JOIN ALP_tblArAlpSiteSys SS ON RB.CustId = SS.CustId     
  --mah 1/4/16, added:  
  LEFT OUTER JOIN ALP_tblInItem I ON RBS.ServiceID = I.AlpItemId  
 WHERE RBS.ExtRepPlanId is not null       
        AND RBS.ExtRepPlanId<>0 -- Added by NSK on 19 Sep 2014   
        AND I.AlpServiceType = 5 -- mah 1/6/16         
  AND RBS.SysId = @SysId  
  --mah 1/4/16, added:    
  AND SS.SysId = @SysId      
        AND ((RBS.Status = 'Cancelled' AND RBS.CanServEndDate >= @ItemDate)      
   OR     
   --The blow condition modified by NSK on 18 Apr 2017. Status <> 'Cancelled' modified as status not in('Cancelled','Expired')
   (RBS.Status not in('Cancelled','Expired') AND (RBS.FinalBillDate is  null Or RBS.FinalBillDate >=@ItemDate))    
   )  
  
   --mah added order by, to ensure that if there are multiple plans, the latest one appears first   
 ORDER BY RBS.ServiceStartDate desc     
    
 return