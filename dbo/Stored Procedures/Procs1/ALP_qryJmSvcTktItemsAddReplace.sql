
CREATE PROCEDURE dbo.ALP_qryJmSvcTktItemsAddReplace
@ID int
As
SET NOCOUNT ON
SELECT ALP_tblJmSvcTktItem.TicketId, ALP_tblJmResolution.[Action]
FROM ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId
WHERE ALP_tblJmSvcTktItem.TicketId = @ID AND (ALP_tblJmResolution.[Action]='Add' Or ALP_tblJmResolution.[Action] = 'Replace')