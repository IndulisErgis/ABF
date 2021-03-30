
CREATE PROCEDURE dbo.ALP_qryJmSvcTktTimeCardLeadTech
@ID int, @Tech int
As
SET NOCOUNT ON
SELECT ALP_tblJmSvcTkt.TicketId, ALP_tblJmTimeCard.TechID
FROM ALP_tblJmSvcTkt INNER JOIN ALP_tblJmTimeCard ON (ALP_tblJmSvcTkt.LeadTechId = ALP_tblJmTimeCard.TechID) AND (ALP_tblJmSvcTkt.TicketId = ALP_tblJmTimeCard.TicketId)
WHERE ALP_tblJmSvcTkt.TicketId = @ID AND ALP_tblJmTimeCard.TechID = @Tech