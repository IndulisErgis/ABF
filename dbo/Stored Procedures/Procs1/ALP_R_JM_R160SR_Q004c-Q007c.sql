




CREATE PROCEDURE [dbo].[ALP_R_JM_R160SR_Q004c-Q007c]
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;
--Converted from Access 12/02 - ER
SELECT 
qry76.CosOffset, 
Sum(qry76.LaborCostExt) AS SumOfLaborCostExt

FROM 
(ALP_tblJmSvcTkt as ST 
INNER JOIN ufxALP_R_AR_Jm_Q004_OpenProjJobsWIP(@EndDate) AS qry4
ON ST.[ProjectId] = qry4.[ProjectId]) 
INNER JOIN ufxALP_R_AR_Jm_Q007c_TimeCards_WIPOffsets_Q006(@EndDate) AS qry76
ON ST.[TicketId] = qry76.[TicketId]

--Added WHERE clause from JM_Q004_OpenProjJobsWIP here to correct closed tickets from appearing - 12/16/15 - ER	
WHERE  ((((ST.CompleteDate) Is Null) 
	AND ((ST.CancelDate) Is Null 
	Or (ST.CancelDate)>@EndDate)) 
	OR (((ST.CompleteDate)>@EndDate) 
	AND ((ST.CancelDate) Is Null)))	
	AND ST.CreateDate <= @EndDate


GROUP BY 
qry76.CosOffset

END