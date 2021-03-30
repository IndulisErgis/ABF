  
CREATE VIEW [dbo].[ALP_IV_TicketTrips] 
-- created by MAH 10/5/15, for use in JM Interactive Views 
AS  
SELECT   
ST.OrderDate,  
TECH.Name,  
ST.SiteId,  
ST.TicketId,
ST.Status,
ST.ProjectID,  
WC.WorkCode,  
ST.WorkDesc,  
RP.RepPlan,  
ST.SalesRepID
,TC.StartDate
,TC.EndDate
,dbo.ALP_ufxConvertToTimeFormat(TC.StartTime) AS StartTime
,dbo.ALP_ufxConvertToTimeFormat(TC.EndTime) AS EndTime
,(EndTime - StartTime) / 60.00 AS Hrs 
,TC.BillableHrs
,TC.Points
,TC.TimeCardComment
,TCCode.TimeCode
FROM ALP_tblJmSvcTkt ST  
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