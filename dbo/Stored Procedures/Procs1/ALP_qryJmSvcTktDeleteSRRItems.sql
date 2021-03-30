
CREATE Procedure dbo.ALP_qryJmSvcTktDeleteSRRItems
@ID int
AS
SET NOCOUNT ON
DELETE dbo.ALP_tblJmSvcTktItem
FROM ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId
WHERE ALP_tblJmSvcTktItem.TicketId= @ID 
	AND (ALP_tblJmResolution.[Action]='Service' OR ALP_tblJmResolution.[Action]='Remove' OR ALP_tblJmResolution.[Action]='Replace')