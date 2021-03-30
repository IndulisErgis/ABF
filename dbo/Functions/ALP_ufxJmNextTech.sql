
CREATE FUNCTION [dbo].[ALP_ufxJmNextTech] 
(
@TicketId Integer
)
RETURNS varchar(5) 
AS 
-- created by MAH 3/4/16 for Scheduler Jobs List and JM Staging usage
BEGIN
	DECLARE @Today as date 
	DECLARE @NextSchedDate as date
	DECLARE @NextSchedTime as int
	DECLARE @NextSchedTech as varchar(5)
	DECLARE @NextTechId as int
	SET @Today = GetDate() 
	SET @NextSchedDate = NULL
	SET @NextSchedTime = 0
	SET @NextSchedTech = NULL  
	SET @NextTechId = NULL 
	SET @NextSchedDate =   (SELECT  MIN(CASE WHEN TC.StartDate >= @Today THEN TC.StartDate ELSE NULL END)   
							FROM  dbo.ALP_tblJmTimeCard TC  
							WHERE TC.TicketID = @TicketID  
							GROUP BY TC.TicketId  ) 
	SET @NextSchedTime = (SELECT MIN(CASE WHEN StartTime IS NULL THEN 1440 ELSE StartTime END)  
							FROM ALP_tblJmTimeCard TC   
							WHERE TC.TicketID = @TicketID AND TC.StartDate   = @NextSchedDate
							AND @NextSchedDate IS NOT NULL  
							GROUP BY  TC.TicketId) 
	SET @NextTechId  = (SELECT MIN(CASE WHEN TechId IS NULL THEN 999 ELSE TechId END)  
							FROM ALP_tblJmTimeCard TC   
							WHERE TC.TicketID = @TicketID AND TC.StartDate   = @NextSchedDate 
							AND TC.StartTime = @NextSchedTime  
							AND @NextSchedTime > 0  
							GROUP BY  TC.TicketId) 
	SET @NextSchedTech = (SELECT Tech.Tech FROM ALP_tblJmTech Tech WHERE Tech.TechId = @NextTechId )  
   	return @NextSchedTech
END