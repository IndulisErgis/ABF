


CREATE FUNCTION [dbo].[ufxALP_R_JM_Q025_FirstSchedDate]()
RETURNS TABLE
AS
RETURN
(

--converted from access qryJm-Q025-FirstSchedDate - 3/26/15 - ER
SELECT 
TC.TicketId,
MIN(TC.StartDate) AS FirstSchedDate

FROM ALP_tblJmTimeCard AS TC

GROUP BY TC.TicketId
)