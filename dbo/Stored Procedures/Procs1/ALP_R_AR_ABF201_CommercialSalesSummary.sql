CREATE PROCEDURE [dbo].[ALP_R_AR_ABF201_CommercialSalesSummary]
(
@StartDate datetime, 
@EndDate datetime 
)
AS

SELECT 
	PI.ContrYY, 
	PI.ContrMM, 
	PI.ContrYYMM, 
	ADiv.Name AS DivName, 
	AD.Name AS DeptName, 
	PI.SalesRepID, 
	PI.OrderDate AS ContrDt, 
	PI.ProjectID, 
	PI.JobPrice AS Price, 
	PI.ContractMths AS MOC, 
	PI.EstCost AS Cost, 
	PI.RMRAdded AS RInc, 
	PI.RMRExpense AS RExp, 
	PI.CommAmt AS Commission, 
	SR.Name	
FROM 
(
(ALP_tblArSalesRep_view AS SR
	INNER JOIN ufxABFRpt201ProjInfo(@StartDate, @EndDate) AS PI
		ON SR.SalesRepID = PI.SalesRepID) 
	INNER JOIN ALP_tblArAlpDept AS AD
		ON (PI.DeptID = AD.DeptId) AND (PI.DeptID = AD.DeptId)) 
	INNER JOIN ALP_tblArAlpDivision AS ADiv
		ON PI.DivID = ADiv.DivisionId
		
WHERE (PI.OrderDate Between @StartDate AND @EndDate)

ORDER BY PI.ContrYY, PI.ContrMM, PI.SalesRepID
;