

CREATE FUNCTION [dbo].[ufxALP_R_JM_Q039_MaxTimeCardDate]()
RETURNS TABLE
AS
RETURN
(

--converted from access qryJm-Q039-MaxTimeCardDate - 3/25/15 - ER
SELECT 
ST.TicketId, 
Max(StartDate) AS MaxSchDate
FROM ALP_tblJmSvcTkt AS ST
INNER JOIN ALP_tblJmTimeCard AS TC
ON ST.TicketId = TC.TicketId

WHERE (((ST.Status)<>'closed' AND (ST.Status)<>'canceled' AND(ST.Status)<>'completed'))

GROUP BY ST.TicketId

)