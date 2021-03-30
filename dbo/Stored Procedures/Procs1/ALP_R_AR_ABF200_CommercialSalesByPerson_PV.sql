CREATE PROCEDURE [dbo].[ALP_R_AR_ABF200_CommercialSalesByPerson_PV]
(
@BeginDate dateTime,
@EndDate dateTime
)
AS
SELECT
	PI.ContrYY, 	
	PI.ContrMM, 	
	PI.ContrYYMM AS YYMM, 	
	PI.ContrYYMM, 	
	PI.SalesRepID, 	
	PI.CustName, 	
	PI.OrderDate AS ContrDt, 	
	PI.ProjectID, 	
	PI.CustID, 	
	PI.SiteId, 	
	PI.JobPrice AS Price, 	
	PI.ContractMths AS MOC, 
	PI.EstCost AS Cost, 	
	PI.RMRAdded AS RInc, 	
	PI.RMRExpense AS RExp, 	
	PI.CommAmt AS Commission, 
		CASE PI.LseYn
		WHEN 0 THEN 'P' ELSE 'L' END AS LorP,
	SR.Name, 
	ASite.SiteName
	
FROM 
	ufxABFRpt200ProjInfo(@BeginDate,@EndDate) AS PI 
		INNER JOIN ALP_tblArSalesRep_view AS SR 
			ON PI.SalesRepID = SR.SalesRepID 
		INNER JOIN ALP_tblArAlpSite_view AS ASite 
			ON PI.SiteId = ASite.SiteId
WHERE 
	PI.OrderDate Between @BeginDate And @EndDate 
	
ORDER BY PI.ContrYY,	PI.ContrMM