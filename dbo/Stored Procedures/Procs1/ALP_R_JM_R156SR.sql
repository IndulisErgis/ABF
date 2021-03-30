



CREATE PROCEDURE [dbo].[ALP_R_JM_R156SR]
	@StartDate dateTime,
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;
--Converted from Access qryJM-SR156 12/26 - ER
SELECT 
Rep.AlpCosOffset, 
Sum(STCS.CommAmt) AS SumOfCommAmt

FROM 
 (ALP_tblJmSvcTkt AS ST 
 INNER JOIN ALP_tblJmSvcTktCommSplit AS STCS
 ON ST.[TicketId] = STCS.[TicketID]) 
 INNER JOIN ALP_tblArSalesRep_view AS Rep
 ON STCS.[SalesRep] = Rep.[SalesRepID]

WHERE
(((ST.CompleteDate) Between @StartDate And @EndDate) 
AND ((ST.ProjectId) Is Null 
Or (ST.ProjectId)=''))

GROUP BY 
Rep.AlpCosOffset

END