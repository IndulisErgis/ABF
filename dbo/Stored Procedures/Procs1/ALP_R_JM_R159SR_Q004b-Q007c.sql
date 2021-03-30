





CREATE PROCEDURE [dbo].[ALP_R_JM_R159SR_Q004b-Q007c]
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;
--Converted from Access 11/25 - ER
SELECT 
qry76.CosOffset, 
Sum(qry76.LaborCostExt) AS SumOfLaborCostExt

FROM 
(ALP_tblJmSvcTkt AS ST
INNER JOIN ufxALP_R_AR_Jm_Q004_OpenSvcJobsWIP(@EndDate) AS qry4  
ON ST.[TicketId] = qry4.[TicketId]) 
LEFT OUTER JOIN ufxALP_R_AR_Jm_Q007c_TimeCards_WIPOffsets_Q006(@EndDate) AS qry76
ON ST.[TicketId] = qry76.[TicketId]

WHERE ST.CreateDate <= @EndDate

GROUP BY 
qry76.CosOffset

END