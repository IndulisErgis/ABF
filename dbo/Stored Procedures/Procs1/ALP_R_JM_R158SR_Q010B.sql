

CREATE PROCEDURE [dbo].[ALP_R_JM_R158SR_Q010B]
	@StartDate dateTime,
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;
--Converted from Access qryJM-SR158-Q010b 12/29 - ER
SELECT 
Rep.AlpCosOffset, 
Sum(ST.CommAmt) AS SumOfCommAmt

FROM 
((ALP_tblJmSvcTkt AS ST 
INNER JOIN ALP_tblJmSvcTktCommSplit AS STCS
ON ST.[TicketId] = STCS.[TicketID]) 
INNER JOIN ALP_tblArSalesRep_view AS Rep
ON STCS.[SalesRep] = Rep.[SalesRepID]) 
INNER JOIN ufxALP_R_AR_Jm_Q010b_CompletedProjIds_Q004c(@EndDate) AS qry10b4
ON ST.[ProjectId] = qry10b4.[ProjectId]

WHERE
(((ST.ProjectId) Is Not Null) 
AND ((qry10b4.ProjCompleteDate) Between @StartDate And @EndDate))

GROUP BY 
Rep.AlpCosOffset

END