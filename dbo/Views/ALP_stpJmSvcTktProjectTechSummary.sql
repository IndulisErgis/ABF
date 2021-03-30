
CREATE VIEW dbo.ALP_stpJmSvcTktProjectTechSummary
--EFI# 1613 MAH 12/20/05 - added labor cost
AS
SELECT  ST.ProjectId, TC.TechID, MIN(T.Tech) AS FirstOfTech, 
        SUM((TC.EndTime - TC.StartTime) / 60.00) AS TotalHours, 
	SUM(TC.Points) AS TotalPoints,
	--EFI# 1613 MAH 12/20/05 - added: labor cost
	SUM(CASE 
		WHEN TC.PayBasedOn <> 1 
			THEN TC.LaborCostRate * ((TC.EndTime -TC.StartTime) / 60.00) 
		ELSE 0 
		END) 
		AS LaborCost_Hours,
	SUM(CASE 
		WHEN TC.PayBasedOn = 1 THEN 
			(TC.Points * TC.PworkRate) + (TC.Points * TC.PworkRate * ST.PworkLabMarkupPct)
		ELSE 0 
		END) 
		AS LaborCost_Piecework
FROM    dbo.ALP_tblJmSvcTkt ST 
	INNER JOIN dbo.ALP_tblJmTech T 
	INNER JOIN dbo.ALP_tblJmTimeCard TC ON T.TechId = TC.TechID ON ST.TicketId = TC.TicketId 
	INNER JOIN dbo.ALP_tblJmSvcTktProject P ON ST.ProjectId = P.ProjectId
GROUP BY ST.ProjectId, TC.TechID