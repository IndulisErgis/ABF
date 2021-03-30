



/* from qryJm-R177B-Q033 */
CREATE PROCEDURE [dbo].[ALP_R_AR_R177B_JobCost]
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
CONVERT(varchar(10), InvcDate,101) as InvcDate2,
SVCTKT.ProjectId,
SVCTKT.TicketId AS TicketId, 
SITE.SiteName AS SiteName, 
cast(Taxable as int) as Taxable, 
--added decimal formatting to fix rounding error in subtotals - ERR - 1/27/16
cast(CASE Taxable when 1 then Sum(Q33B.PartCost) else 0.00 end as decimal(18,2)) as TaxableParts,
cast(CASE Taxable when 0 then Sum(Q33B.PartCost) else 0.00 end as decimal(18,2)) as NontaxableParts,
Sum(Q33B.PartCost) AS PartCost, 
Sum(Q33B.PartOh) AS PartOh, 
Sum(Q33B.OtherCost) AS OtherCost, 
--added new field to break out part costs - ERR - 9/9/15
Sum(Q33B.OtherPartCost) AS OtherPartCost, 
--added new fields for summing other part costs - ERR - 1/26/16
--added decimal formatting to fix rounding error in subtotals - ERR - 1/27/16
cast(CASE Taxable when 1 then Sum(Q33B.OtherPartCost) else 0.00 end as decimal(18,2)) as TaxableOtherParts,
cast(CASE Taxable when 0 then Sum(Q33B.OtherPartCost) else 0.00 end as decimal(18,2)) as NontaxableOtherParts,
Sum(Q33B.LaborCost) AS LaborCost, 
Sum(Q33B.CommCost) AS CommCost, 
Sum(Q33B.JobCost) AS JobCost,  
Sum(SVCTKT.PartsPrice) AS SumOfPartsPrice, 
Sum(SVCTKT.LabPriceTotal) AS SumOfLabPriceTotal, 
Sum(Q33B.OtherPrice) AS SumOfOtherPrice, 
Sum([PartsPrice]+[LabPriceTotal]+[OtherPrice]) AS TotPrice

FROM 
ALP_tblJmSvcTkt AS SVCTKT
	INNER JOIN ALP_tblArAlpSite AS SITE
		ON SVCTKT.SiteId = SITE.SiteId 
	INNER JOIN ALP_tblJmWorkCode 
		ON SVCTKT.WorkCodeId = ALP_tblJmWorkCode.WorkCodeId 
	INNER JOIN ALP_tblArAlpBranch 
		ON SVCTKT.BranchId = ALP_tblArAlpBranch.BranchId 
	INNER JOIN ufxALP_R_AR_Jm_Q033B_ProjJobCostDetail() AS Q33B 
		ON SVCTKT.TicketId = Q33B.TicketId

WHERE SVCTKT.CompleteDate 
	Between @StartDate And @EndDate 
	AND (SVCTKT.Status ='Completed' Or SVCTKT.Status = 'Closed') 
	AND SVCTKT.ProjectId Is Not Null
	
GROUP BY 
ALP_tblArAlpBranch.Branch, 
CASE WHEN LseYn=0 THEN GlAcctSaleCOS ELSE GlAcctLseCOS END, 
SVCTKT.ProjectId,
SVCTKT.TicketId, 
SVCTKT.InvcDate,
Q33B.JobCost,
SiteName,Taxable

END