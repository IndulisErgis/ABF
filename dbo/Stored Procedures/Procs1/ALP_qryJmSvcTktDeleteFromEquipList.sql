
CREATE Procedure dbo.ALP_qryJmSvcTktDeleteFromEquipList
@ID int
AS
SET NOCOUNT ON
DELETE dbo.ALP_tblArAlpSiteSysItem
FROM ALP_tblJmResolution INNER JOIN (ALP_tblArAlpSiteSysItem INNER JOIN ALP_tblJmSvcTktItem 
	ON (ALP_tblArAlpSiteSysItem.SysItemId = ALP_tblJmSvcTktItem.SysItemId) AND (ALP_tblArAlpSiteSysItem.TicketId = ALP_tblJmSvcTktItem.TicketId)) 
	ON ALP_tblJmResolution.ResolutionId = ALP_tblJmSvcTktItem.ResolutionId
WHERE ALP_tblArAlpSiteSysItem.TicketId = @ID AND ALP_tblArAlpSiteSysItem.RemoveYN = 0 AND ALP_tblJmResolution.[Action] ='Add'