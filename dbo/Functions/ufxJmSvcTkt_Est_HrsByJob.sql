



CREATE FUNCTION [dbo].[ufxJmSvcTkt_Est_HrsByJob] 
	(
	@ProjectId varchar(10) = null,
	@TicketID int = null
	)
RETURNS decimal(20,2) AS  
BEGIN 
	RETURN (
		SELECT    Round(Sum(EstHrs_FromQM),2) AS EstJobHrs
		FROM         ALP_tblJmSvcTkt 
		WHERE 
			((@TicketID is not null and ALP_tblJmSvcTkt.TicketID = @TicketID)
			or (@TicketID is  null and ALP_tblJmSvcTkt.ProjectId = @ProjectId)
		and ALP_tblJmSvcTkt.Status<>'cancelled')
		--added to differentiate tickets added after original estimate 11/6/19 - ER
		and ALP_tblJmSvcTkt.OriginalEstimatesflg = '1'
		
		)

END