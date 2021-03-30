

CREATE PROCEDURE [dbo].[ALP_R_AR_R175_JobCostSummary]
	@StartDate datetime,
	@EndDate dateTime
AS
BEGIN
SET NOCOUNT ON;

SELECT 
BRANCH.Branch, 
CASE 
WHEN SVCTKT.LseYn=0 THEN GlAcctSaleCOS ELSE GlAcctLseCOS END AS CosAcct, 
SVCTKT.TicketId, 
AAS.SiteName, 
SVCJCD.PartCost, 
SVCJCD.PartOh, 
SVCJCD.OtherCost, 
--Added additional field - ER - 9/8/15
SVCJCD.OtherPartCost, 
SVCJCD.LaborCost, 
SVCJCD.CommCost, 
SVCJCD.JobCost

FROM ALP_tblJmSvcTkt AS SVCTKT 

INNER JOIN ALP_tblArAlpSite AS AAS 
	ON SVCTKT.SiteId = AAS.SiteId 
INNER JOIN ALP_tblJmWorkCode 
	ON SVCTKT.WorkCodeId = ALP_tblJmWorkCode.WorkCodeId 
INNER JOIN ALP_tblArAlpBranch AS BRANCH
	ON SVCTKT.BranchId = BRANCH.BranchId 
INNER JOIN ufxALP_R_AR_Jm_Q031_SvcJobCostDetail() AS SVCJCD 

ON SVCTKT.TicketId = SVCJCD.TicketId

WHERE SVCTKT.CompleteDate Between @StartDate And @EndDate

END