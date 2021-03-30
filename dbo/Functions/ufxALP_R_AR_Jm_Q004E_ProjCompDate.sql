
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q004E_ProjCompDate] 
(	
	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT SvcTkt.ProjectId, 
MAX(IsNull(CompleteDate,'3000-01-01')) AS CompDate,
MAX(ISNULL(CloseDate,'3000-01-01')) AS ClosedDate


FROM ALP_tblJmSvcTkt AS SvcTkt

GROUP BY 
SvcTkt.ProjectId

HAVING 
(((SvcTkt.ProjectId) Is Not Null))

)