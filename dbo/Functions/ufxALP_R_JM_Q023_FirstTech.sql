

CREATE FUNCTION [dbo].[ufxALP_R_JM_Q023_FirstTech]()
RETURNS TABLE
AS
RETURN
(

--converted from access qryJm-Q023-FirstTech - 3/26/15 - ER
SELECT 
TC.TicketId,
MAX(TECH.Tech) AS TimeCardTech

FROM ALP_tblJmTimeCard AS TC
INNER JOIN ALP_tblJmTech AS TECH
ON TC.TechID = TECH.TechId

GROUP BY TC.TicketId
)