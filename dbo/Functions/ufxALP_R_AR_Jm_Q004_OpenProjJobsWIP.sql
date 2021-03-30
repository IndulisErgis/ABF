

CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q004_OpenProjJobsWIP] 
(	
	@EndDate dateTime
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
SvcTkt.ProjectId

FROM ALP_tblJmSvcTkt AS SvcTkt

WHERE  (((SvcTkt.CompleteDate) Is Null) 
	AND ((SvcTkt.CancelDate) Is Null 
	Or (SvcTkt.CancelDate)>@EndDate)) 
	OR (((SvcTkt.CompleteDate)>@EndDate) 
	AND ((SvcTkt.CancelDate) Is Null))

GROUP BY SvcTkt.ProjectId

HAVING SvcTkt.ProjectId Is Not Null

)