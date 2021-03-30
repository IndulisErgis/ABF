
CREATE FUNCTION [dbo].[ufxJm_Q024_TechsOnJobs] 
(	
)
--converted from access qryJm-Q024-TechsOnJobs - 3/30/2015 - ER

RETURNS TABLE 
AS
RETURN 
(
SELECT 
TicketId,TechID

FROM 
ALP_tblJmTimeCard

GROUP BY
TicketId,TechID

)