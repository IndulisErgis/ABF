
-- =============================================
-- from qryJm-Q015-EstHoursByJob_FromQM - 2/3/16 - ER
-- =============================================
CREATE FUNCTION [dbo].[ufxJm_Q015_EstHoursByJob_FromQM] 
(	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
SvcTkt.ProjectId, 
SvcTkt.TicketId, 
SvcTkt.EstHrs_FromQM

FROM 
ALP_tblJmSvcTkt AS SvcTkt

WHERE 
SvcTkt.ProjectId Is Not Null 
AND SvcTkt.Status<>'cancelled'
)