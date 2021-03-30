


CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q004E_ProjDates] 
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT SvcTkt.ProjectId, 
IsNull(CompleteDate,'3000-01-01') AS CompDate,
ISNULL(CloseDate,'3000-01-01') AS ClosedDate


FROM ALP_tblJmSvcTkt AS SvcTkt

GROUP BY 
SvcTkt.ProjectId, 
IsNull(CompleteDate,'3000-01-01'), 
ISNULL(CloseDate,'3000-01-01')

HAVING 
(((SvcTkt.ProjectId) Is Not Null))

)