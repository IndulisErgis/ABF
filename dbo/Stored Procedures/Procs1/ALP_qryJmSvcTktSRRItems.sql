CREATE PROCEDURE dbo.ALP_qryJmSvcTktSRRItems  
@ID int  
As  
SET NOCOUNT ON  
SELECT ALP_tblJmSvcTktItem.TicketId, ALP_tblJmResolution.[Action]
,ALP_tblJmSvcTktItem.TicketItemId,ALP_tblJmSvcTktItem.QtySeqNum_Cmtd  --Added by NSK on 25 Sep 2020
FROM ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId  
WHERE ALP_tblJmSvcTktItem.TicketId = @ID  
 AND (ALP_tblJmResolution.[Action] ='Service'  OR ALP_tblJmResolution.[Action] = 'Remove'  OR ALP_tblJmResolution.[Action] = 'Replace')