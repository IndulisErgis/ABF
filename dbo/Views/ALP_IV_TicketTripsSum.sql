CREATE VIEW [dbo].[ALP_IV_TicketTripsSum]  
-- created by MAH 10/5/15, for use in JM Interactive Views
AS  
SELECT   
COUNT(TC.TimeCardID) AS Visits  
,ST.TicketId
,MIN(ST.Status) AS Status
,TCCode.TimeCode
,ST.SiteID
,MIN(TC.StartDate) as FirstVisit
,MAX(TC.EndDate) AS LastVisit
, SUM((EndTime - StartTime) / 60.00) AS TotHrs 
, SUM(TC.BillableHrs) as BillableHrs
,SUM(TC.Points) as Points
FROM ALP_tblJmSvcTkt AS ST  
 INNER JOIN ALP_tblArAlpRepairPlan AS RP  
  ON ST.RepPlanId = RP.RepPlanId  
 INNER JOIN ALP_tblJmWorkCode AS WC  
  ON ST.WorkCodeId = WC.WorkCodeId  
INNER JOIN ALP_tblJmTimeCard TC
	ON  ST.TicketID = TC.TicketID
LEFT OUTER JOIN ALP_tblJMTimeCode TCCode
	ON TC.TimeCodeID = TCCode.TimeCodeID
LEFT OUTER JOIN ALP_tblJmTech AS TECH  
	 ON  TC.TechId = TECH.TechId  
GROUP BY ST.TicketID, ST.SiteId, TCCode.TimeCode