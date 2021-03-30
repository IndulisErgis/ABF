



CREATE PROCEDURE [dbo].[ALP_R_AR_ABF205d_SalesByPerson_PV_MAHTEST] 
(
	@StartDate DateTime,
	@EndDate DateTime,
	@SalesRep varchar(50),
	@Ownership varchar(50)
)
AS
--Created from ABF205C for testing - 6/2/2015
BEGIN
	SET NOCOUNT ON
SELECT 
	ContrYY+ContrMM AS YYMM, 
	PI.ContrYY, 
	PI.ContrMM, 
	PI.SalesRepID,
	--060315 mah:
	PI.CancelDate, 
	PI.OrderDate,
	PI.ProjectID, 
	PI.ContractID, 
	PI.CustName, 
	PI.CustID, 
	PI.SiteId, 
	PI.CO, 
	PI.ContractValue, 
	PI.ProjDesc,
	ISNULL(JobPrice,0) AS Price, 
	ISNULL(ContractMths,0) AS MOC, 
	EstCost AS Cost, 
	ISNULL(RMRAdded,0) AS RInc, 
	ISNULL(RMRExpense,0) AS RExp, 
	ISNULL(CommAmt,0) AS Commission, 
	--MAH 06/30/14: remove separation between Purchased and Leased systems:
	--CASE PI.LseYn WHEN 0 THEN 'P' WHEN 1 THEN 'L' ELSE '-' END AS LorP,
	--CASE PI.LseYn WHEN 0 THEN 'P' ELSE 'L' END AS LorP,
	Pi.LseYn AS LorP,
	SR.Name, 
	ASite.SiteName

FROM ALP_tblArAlpSite AS ASite
	INNER JOIN ALP_tblArSalesRep_view AS SR 
	INNER JOIN (
		SELECT * 
		FROM ufxABFRpt205D_ProjInfo(@StartDate,@EndDate)) AS PI
	ON SR.SalesRepID = PI.SalesRepID 
	ON ASite.SiteId=PI.SiteId

WHERE 
(
	--(PI.OrderDate Between ISNULL(@StartDate,'01/01/01')	And ISNULL(@EndDate, GetDate() ))
	(PI.CancelDate Between ISNULL(@StartDate,'01/01/01')	And ISNULL(@EndDate, GetDate() ))
	AND
	((PI.SalesRepID = @SalesRep) OR (@SalesRep = '<ALL>'))
	AND
	((PI.LseYn = @Ownership) OR (@Ownership = '<ALL>'))
	-- AND PI.ContractValue<>0 -- JVH 02-08-2014 remove zero value contracts
)

ORDER BY 
	PI.ContrYY, 
	PI.ContrMM, 
	PI.SalesRepID,
	PI.CancelDate DESC
	--PI.OrderDate DESC 

END