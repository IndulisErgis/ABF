
CREATE VIEW dbo.ALP_lkpJmSvcTktProjectTechSummary_Count
--EFI# 1613 MAH 12/20/05 - added labor cost data
AS
SELECT  COUNT(ProjectId) AS CountOfProjectId, 
	SUM(TotalPoints) AS SumOfTotalPoints, 
	SUM(TotalHours) AS SumOfTotalHours, 
	ProjectId,
	--EFI# 1613 MAH 12/20/05 added:
	SUM(LaborCost_Hours + LaborCost_Piecework) AS SumOfLaborCost
FROM         dbo.ALP_stpJmSvcTktProjectTechSummary
GROUP BY ProjectId