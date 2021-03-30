CREATE FUNCTION [dbo].[ufxJmSvcTkt_ActualHrs] 
	(
	@TicketID int = null
	)
RETURNS decimal(20,2) AS  
BEGIN 
	RETURN (
		SELECT     SUM((EndTime - StartTime) / 60.00) AS ActualHrs
		FROM         ALP_tblJmTimeCard
		WHERE 
			(@TicketID is null OR ALP_tblJmTimeCard.TicketID = @TicketID)
		)

END