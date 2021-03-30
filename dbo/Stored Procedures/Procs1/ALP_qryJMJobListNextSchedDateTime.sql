CREATE PROCEDURE [dbo].[ALP_qryJMJobListNextSchedDateTime]    
AS 
--created 3/3/2016 by MAH for Scheduler application - Job List
DECLARE @Today as date
SET @Today = GetDate() 
  
SELECT TicketId INTO #SchedTickets
FROM ALP_tblJmSvcTkt where Status = 'scheduled'
ORDER BY TicketId
SELECT     TC.TicketId,
	MAX(TC.StartDate)  as MaxStartDate, 000 as NextSchedTime, 000 as TimeCardId, 000 as TechId ,
	MAX(CASE WHEN TC.StartDate < @Today THEN TC.StartDate ELSE NULL END) AS LastVisit,   
	MIN(CASE WHEN TC.StartDate >= @Today THEN TC.StartDate ELSE NULL END) AS NextSchedDate  
	INTO #TicketDates
FROM  dbo.ALP_tblJmTimeCard TC INNER JOIN #SchedTickets  T ON TC.TicketID = T.TicketID
GROUP BY TC.TicketId 
ORDER BY TC.TicketId 
 
UPDATE #TicketDates
SET NextSchedTime = (SELECT	MIN(CASE WHEN StartTime IS NULL THEN 1440 ELSE StartTime END) 	FROM ALP_tblJmTimeCard TC 
		WHERE #TicketDates.TicketId = TC.TicketId AND #TicketDates.NextSchedDate = TC.StartDate 
		AND #TicketDates.NextSchedDate IS NOT NULL
		GROUP BY  TC.TicketId)	
FROM ALP_tblJmTimeCard TC INNER JOIN #TicketDates ON 
		#TicketDates.TicketId = TC.TicketId AND #TicketDates.NextSchedDate = TC.StartDate 
WHERE #TicketDates.NextSchedDate IS NOT NULL

UPDATE #TicketDates
SET TechId  = (SELECT MIN(CASE WHEN TechId IS NULL THEN 999 ELSE TechId END) 	FROM ALP_tblJmTimeCard TC 
		WHERE #TicketDates.TicketId = TC.TicketId AND #TicketDates.NextSchedDate = TC.StartDate 
		AND #TicketDates.NextSchedTime = TC.StartTime 
		AND #TicketDates.NextSchedDate IS NOT NULL AND #TicketDates.NextSchedTime > 0
		GROUP BY  TC.TicketId)
FROM ALP_tblJmTimeCard TC INNER JOIN #TicketDates ON 
		#TicketDates.TicketId = TC.TicketId AND #TicketDates.NextSchedDate = TC.StartDate 
		AND #TicketDates.NextSchedTime = TC.StartTime 
WHERE #TicketDates.NextSchedTime > 0 AND #TicketDates.NextSchedDate IS NOT NULL

select TicketId, LastVisit, NextSchedDate, 
CAST(CAST(DATEADD(minute,NextSchedTime,'2000.01.01') AS TIME) AS VARCHAR(5)) AS NextSchedTime, 
Tech.TechId, Tech.Tech, Tech.Name, MaxStartDate from  #TicketDates INNER JOIN ALP_tblJmTech Tech ON #TicketDates.TechId = Tech.TechId

drop table #SchedTickets
drop table #TicketDates