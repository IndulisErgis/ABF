CREATE Procedure dbo.ALP_stpJmSvcTktProject_sp      
 (      
  @SiteId int = NULL      
 )      
As      
set nocount on      
SELECT SvcTktProjectId, ProjectId, SiteId, [Desc], PromoId,       
    LeadSourceId, ReferBy, FudgeFactor, AdjPoints, AdjComments,       
    EstMatCost, EstLabCost, EstLabHrs, NewWorkYn,       
    MarketCodeId, FudgeFactorHrs, AdjHrs, InitialOrderDate,       
    Contact, ContactPhone, BranchID, CustPoNum,    
    --added by NSK on 29 may 2015    
    LeadSalesRepID,  
    --added by NSK on 31 Dec 2015  
    BillingNotes,ProjectNotes    
    --added by NSK on 19 Dec 2018 for bug id 868
    ,HoldProjInvCommitted
FROM dbo.ALP_tblJmSvcTktProject       
WHERE  ( SiteId = @SiteID)      
ORDER BY SiteID DESC,ProjectID DESC      
return