CREATE PROCEDURE [dbo].[ALP_R_AR_ABF220_PropertyTaxRpt]
(
	@StartDate DateTime,
	@EndDate DateTime
)
AS
BEGIN
	SET NOCOUNT ON;

SELECT 
TI.ContrYY, 
TI.ContrMM, 
TI.CustName, 
TI.OrderDate AS ContrDt, 
TI.ProjectID, 
TI.CustID, 
TI.SiteId, 
ISNULL(TI.JobPrice,0) AS Price, 
ISNULL(TI.ContractMths,0) AS MOC, 
TI.EstCost AS Cost, 
ISNULL(TI.RMRAdded,0) AS RInc, 
ISNULL(TI.RMRExpense,0) AS RExp, 
ISNULL(TI.CommAmt,0) AS Commission, 
CASE TI.LseYn	WHEN 0 THEN 'P' ELSE 'L' END AS LorP, 
SITE.SiteName, 
SITE.Addr1,
SITE.Addr2,
SITE.County,
SITE.City,  
SITE.PostalCode AS ZIP,
TI.EstMatCost AS MatCost

FROM ALP_tblArAlpSite AS SITE
	INNER JOIN ufxABFRpt220Leases_ProjInfo(@StartDate,@EndDate) AS TI
		ON SITE.SiteId = TI.SiteId

WHERE TI.OrderDate 
	Between ISNULL(@StartDate,'01/01/01') 
	AND ISNULL(@EndDate,GetDate() ) 
	AND TI.LseYn<>0;

END