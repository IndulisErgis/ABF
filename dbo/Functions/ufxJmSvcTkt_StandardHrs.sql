CREATE FUNCTION dbo.ufxJmSvcTkt_StandardHrs 
	(
	@TicketID int = null
	)
RETURNS decimal(20,2) AS  
BEGIN 
	RETURN (
		SELECT SUM(PCT.EstHrs) AS StandardHrs
		FROM ufxJmSvcTkt_PriceCostTotals(null,@TicketID) PCT
		)

END