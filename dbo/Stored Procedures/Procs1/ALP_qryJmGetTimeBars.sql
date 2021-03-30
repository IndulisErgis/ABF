
CREATE PROCEDURE [dbo].[ALP_qryJmGetTimeBars]
  @StartDate datetime,
  @EndDate  datetime
 AS
SELECT Tech.Tech, TC.TimeCardID, TC.TechID, convert(varchar(10),TC.StartDate,101) StartDate,
convert(varchar(10),TC.EndDate,101) EndDate , TC.StartTime, TC.EndTime, TC.TimeCodeID ,TC.TicketId, 
TCD.TimeCode,TC.LockedYN,TC.TimeCardComment 
FROM         ALP_tblJmTimeCard TC INNER JOIN ALP_tblJmTech Tech ON TC.TechID = Tech.TechId INNER JOIN  
ALP_tblJmTimeCode TCD ON TC.TimeCodeID = TCD.TimeCodeID 
where TC.StartDate >= CONVERT(DATETIME, @StartDate, 101) 
and TC.EndDate <= CONVERT(DATETIME, @EndDate, 101)