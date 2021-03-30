
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q004_OpenSvcJobsWIP] 
(	
	@EndDate dateTime
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
SvcTkt.TicketId

FROM ALP_tblJmSvcTkt AS SvcTkt

WHERE (((SvcTkt.ProjectId) Is Null) 
	AND ((SvcTkt.CompleteDate) Is Null) 
	AND ((SvcTkt.CancelDate) Is Null 
	Or (SvcTkt.CancelDate)>@EndDate)) 
	OR (((SvcTkt.ProjectId) Is Null) 
	AND ((SvcTkt.CompleteDate)>@EndDate) 
	AND ((SvcTkt.CancelDate) Is Null))

GROUP BY SvcTkt.TicketId
)