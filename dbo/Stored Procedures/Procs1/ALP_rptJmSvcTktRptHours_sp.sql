
CREATE PROCEDURE dbo.ALP_rptJmSvcTktRptHours_sp
(
@TicketID int
)
AS
SET NOCOUNT ON
SELECT 
ALP_tblJmTimeCard.TicketId, 
ALP_tblJmTech.Name, 
ALP_tblJmTimeCard.StartDate, 
ALP_tblJmTimeCard.BillableHrs
FROM ALP_tblJmTimeCard 
INNER JOIN ALP_tblJmTech 
ON ALP_tblJmTimeCard.TechID = ALP_tblJmTech.TechID
where ALP_tblJmTimecard.TicketID=@TicketID