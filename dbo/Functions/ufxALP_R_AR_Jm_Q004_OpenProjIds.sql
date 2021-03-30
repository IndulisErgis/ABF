
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q004_OpenProjIds] 
(	
)
RETURNS TABLE 
AS
RETURN 
(
--Converted from Access 11/20/2014 - ER
SELECT 
ST.ProjectId

FROM ALP_tblJmSvcTkt AS ST

WHERE (((ST.[Status])='New' Or (ST.[Status])='Targeted' Or (ST.[Status])='Scheduled'))

GROUP BY ST.ProjectId

HAVING ST.ProjectId Is not null

)