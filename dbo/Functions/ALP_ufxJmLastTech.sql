
CREATE FUNCTION [dbo].[ALP_ufxJmLastTech] 
(
@TicketId Integer
)
-- created by MAH 5/19/16
RETURNS varchar(5) 
AS 
BEGIN
	DECLARE @Today as date 
	DECLARE @LastSchedDate as date
	DECLARE @LastSchedTime as int
	DECLARE @LastSchedTech as varchar(5)
	DECLARE @LastTechId as int
	SET @Today = GetDate() 
	SET @LastSchedDate = NULL
	SET @LastSchedTime = 0
	SET @LastSchedTech = NULL  
	SET @LastTechId = NULL 
	SET @LastSchedDate =   (SELECT  MAX(CASE WHEN TC.StartDate < @Today THEN TC.StartDate ELSE NULL END)  
							FROM  dbo.ALP_tblJmTimeCard TC  
							WHERE TC.TicketID = @TicketID  
							GROUP BY TC.TicketId  ) 
	SET @LastSchedTime = (SELECT MAX(CASE WHEN StartTime IS NULL THEN 1440 ELSE StartTime END)  
							FROM ALP_tblJmTimeCard TC   
							WHERE TC.TicketID = @TicketID AND TC.StartDate   = @LastSchedDate
							AND @LastSchedDate IS NOT NULL  
							GROUP BY  TC.TicketId) 
	SET @LastTechId  = (SELECT MIN(CASE WHEN TechId IS NULL THEN 999 ELSE TechId END)  
							FROM ALP_tblJmTimeCard TC   
							WHERE TC.TicketID = @TicketID AND TC.StartDate   = @LastSchedDate 
							AND TC.StartTime = @LastSchedTime  
							AND @LastSchedTime > 0  
							GROUP BY  TC.TicketId) 
	SET @LastSchedTech = (SELECT Tech.Tech FROM ALP_tblJmTech Tech WHERE Tech.TechId = @LastTechId )  
   	return @LastSchedTech
END