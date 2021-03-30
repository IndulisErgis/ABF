



CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R411R-Summary]
(
 @StartDate datetime, 
 @EndDate datetime,
 @Branch varchar(255)
 )	
AS
BEGIN
SET NOCOUNT ON

SELECT
Summary.Reason, 
Summary.CanReasonId,
Count(Summary.SiteId) AS CountOfSiteId, 
Sum(Summary.SumOfRMR) AS RMR, 
Sum(Summary.ActiveCount) AS SumOfActiveCount, 
Sum(Summary.InactiveCount) AS SumOfInactiveCount, 
Sum(Summary.PendingCount) AS SumOfPendingCount

FROM 
ufxALP_R_AR_Site_Q411R_SummaryBySite(@StartDate,@EndDate,@Branch) AS Summary

GROUP BY 
Summary.Reason, Summary.CanReasonId

ORDER BY 
Summary.Reason, 
Summary.CanReasonId, 
Count (Summary.SiteId)

END