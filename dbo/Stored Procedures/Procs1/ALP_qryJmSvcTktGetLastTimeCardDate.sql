
CREATE PROCEDURE dbo.ALP_qryJmSvcTktGetLastTimeCardDate
@ID int
As
SET NOCOUNT ON
SELECT dbo.ALP_tblJmSvcTkt.TicketId, Max(dbo.ALP_tblJmTimeCard.EndDate) AS LastDate
FROM dbo.ALP_tblJmSvcTkt INNER JOIN dbo.ALP_tblJmTimeCard ON dbo.ALP_tblJmSvcTkt.TicketId = dbo.ALP_tblJmTimeCard.TicketId
GROUP BY dbo.ALP_tblJmSvcTkt.TicketId
HAVING dbo.ALP_tblJmSvcTkt.TicketId = @ID