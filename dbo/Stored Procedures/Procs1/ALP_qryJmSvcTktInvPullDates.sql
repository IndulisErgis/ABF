
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktInvPullDates]  
@ID int  
As  
SET NOCOUNT ON  
SELECT ALP_tblJmResolution.Action, ALP_tblJmSvcTkt.TicketId, ALP_tblJmSvcTktItem.PartPulledDate  
FROM ALP_tblJmResolution INNER JOIN (ALP_tblJmSvcTkt INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmSvcTkt.TicketId = ALP_tblJmSvcTktItem.TicketId)   
 ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId  
WHERE (ALP_tblJmResolution.[Action] = 'Add' Or ALP_tblJmResolution.[Action] = 'Replace') 
AND ALP_tblJmSvcTkt.TicketId = @ID  
AND (ALP_tblJmSvcTktItem.PartPulledDate Is Null) 
--Added by NSK on Feb 12 2015 to bypass kits and vendor kit components
-- because these parts are not actually pulled from warehouse 
--start
AND (dbo.ALP_tblJmSvcTktItem.KittedYN = 0)            
AND (dbo.ALP_tblJmSvcTktItem.AlpVendorKitComponentYn = 0)   
--end