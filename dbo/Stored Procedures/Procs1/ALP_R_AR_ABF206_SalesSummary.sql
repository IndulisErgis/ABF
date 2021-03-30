
CREATE PROCEDURE [dbo].[ALP_R_AR_ABF206_SalesSummary]
( 
	@BeginOrderDate datetime, 
	@EndOrderDate datetime
)
AS
BEGIN
SET NOCOUNT ON

SELECT  
PI.ContrYY, 
PI.ContrMM, 
PI.ContrYYMM AS ContrDate, 
AAD.Name AS DivName, 
PI.SalesRepID, 
ASR.Name as SalesRepName, 
PI.JobPrice AS Price, 
PI.EstCost AS Cost, 
PI.CommAmt AS Commission,
PI.ContractMths AS MOC, 
PI.RMRAdded AS RInc, 
PI.RMRExpense AS RExp

FROM ALP_tblArSalesRep_view AS ASR
	RIGHT JOIN ALP_tblArAlpDivision AS AAD
	RIGHT JOIN ALP_tblArAlpDept AS ADept 
	RIGHT JOIN ufxABFRpt206ProjInfo(@BeginOrderDate,@EndOrderDate) AS PI
		    ON ADept.DeptId = PI.DeptID 	
		    ON AAD.DivisionId = PI.DivID 
			 ON ASR.SalesRepID = PI.SalesRepID

WHERE PI.OrderDate Between @BeginOrderDate And @EndOrderDate
	 
ORDER BY PI.ContrYYMM
END