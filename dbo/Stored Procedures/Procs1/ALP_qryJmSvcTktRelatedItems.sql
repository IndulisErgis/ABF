
CREATE PROCEDURE dbo.ALP_qryJmSvcTktRelatedItems @ID int
As
SET NOCOUNT ON
SELECT ALP_tblJmSvcTktItem.TicketId
FROM ALP_tblJmSvcTktItem INNER JOIN 
(SELECT ALP_tblJmSvcTktItem.TicketId, ALP_tblJmResolution.Action, ALP_tblJmSvcTktItem.SysItemId
FROM ALP_tblJmResolution INNER JOIN ALP_tblJmSvcTktItem ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId
WHERE ALP_tblJmSvcTktItem.TicketId = @ID AND ALP_tblJmResolution.[Action]='Add') a
 ON ALP_tblJmSvcTktItem.SysItemId = a.SysItemId
WHERE ALP_tblJmSvcTktItem.TicketId <> @ID