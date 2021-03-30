

--converted from access qryJm-R177-Q033 - 02/19/15 - ER
CREATE PROCEDURE [dbo].[ALP_R_AR_R177_JobCost]
(
@StartDate datetime,
@EndDate datetime
)
AS
BEGIN
SET NOCOUNT ON
SELECT 
ALP_tblArAlpBranch.Branch, 
CASE WHEN LseYn=0 THEN GlAcctSaleCOS ELSE GlAcctLseCOS END AS CosAcct, 
SVCTKT.ProjectId,
SITE.SiteName AS SiteName, 
Sum(Q33.PartCost) AS PartCost, 
Sum(Q33.PartOh) AS PartOh, 
--added OtherPartCost 9/8/2015 - ER
SUM(Q33.OtherPartCost) AS OtherPartCost,
Sum(Q33.OtherCost) AS OtherCost, 
Sum(Q33.LaborCost) AS LaborCost, 
Sum(Q33.CommCost) AS CommCost, 
Sum(Q33.JobCost) AS JobCost  
--Sum(SVCTKT.PartsPrice) AS SumOfPartsPrice, 
--Sum(SVCTKT.LabPriceTotal) AS SumOfLabPriceTotal, 
--Sum(Q33.OtherPrice) AS SumOfOtherPrice, 
--Sum([PartsPrice]+[LabPriceTotal]+[OtherPrice]) AS TotPrice

FROM 
ALP_tblJmSvcTkt AS SVCTKT
	INNER JOIN ALP_tblArAlpSite AS SITE
		ON SVCTKT.SiteId = SITE.SiteId 
	INNER JOIN ALP_tblJmWorkCode 
		ON SVCTKT.WorkCodeId = ALP_tblJmWorkCode.WorkCodeId 
	INNER JOIN ALP_tblArAlpBranch 
		ON SVCTKT.BranchId = ALP_tblArAlpBranch.BranchId 
	INNER JOIN ufxALP_R_AR_Jm_Q033_ProjJobCostDetail(@EndDate) AS Q33
		ON SVCTKT.TicketId = Q33.TicketId

WHERE Q33.CompleteDate Between @StartDate And @EndDate 
	
GROUP BY 
ALP_tblArAlpBranch.Branch, 
CASE WHEN LseYn=0 THEN GlAcctSaleCOS ELSE GlAcctLseCOS END, 
SVCTKT.ProjectId,
SITE.SiteName

END