CREATE PROCEDURE dbo.ALP_lkpJmSvcTktProjectId_sp  
@ID int  
As  
SET NOCOUNT ON  
SELECT ALP_tblJmSvcTktProject.ProjectId, ALP_tblJmSvcTktProject.[Desc], ALP_tblJmSvcTktProject.PromoId, ALP_tblJmSvcTktProject.LeadSourceId,   
 ALP_tblJmSvcTktProject.ReferBy, ALP_tblJmSvcTktProject.FudgeFactor, ALP_tblJmSvcTktProject.AdjPoints, ALP_tblJmSvcTktProject.AdjComments,   
 ALP_tblJmSvcTktProject.NewWorkYN 
 --Added by NSK on 17 Dec 2018 for bug id 868
 ,ALP_tblJmSvcTktProject.HoldProjInvCommitted
FROM ALP_tblJmSvcTktProject   
WHERE ALP_tblJmSvcTktProject.SiteId = @ID