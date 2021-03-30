

Create FUNCTION [dbo].[ufxJmSvcTkt_HrsByJob] 
	(
	@TicketID int = null
	)
RETURNS decimal(20,2) AS  
BEGIN 
	RETURN (
		SELECT    Round(Sum(([UnitHrs])*([qty])),2) AS EstJobHrs
		FROM         ALP_R_JmAllActions_view 
		WHERE 
			(@TicketID is null OR ALP_R_JmAllActions_view.TicketID = @TicketID)
		
		
		)

END