
CREATE FUNCTION [dbo].[ALP_ufxJmNextTime] 
(
@TicketId Integer
)
RETURNS varchar(5) 
AS
-- created by MAH 3/4/16 for Scheduler Jobs List and JM Staging usage 
BEGIN
	DECLARE @tm varchar(5) 
	DECLARE @Today as date 
	DECLARE @NextSchedDate as date
	DECLARE @NextSchedTime as int
	SET @Today = GetDate() 
	SET @NextSchedDate = NULL
	SET @NextSchedTime = 0
	SET @NextSchedDate =   (SELECT  MIN(CASE WHEN TC.StartDate >= @Today THEN TC.StartDate ELSE NULL END)   
							FROM  dbo.ALP_tblJmTimeCard TC  
							WHERE TC.TicketID = @TicketID  
							GROUP BY TC.TicketId  ) 
	SET @NextSchedTime = (SELECT MIN(CASE WHEN StartTime IS NULL THEN 1440 ELSE StartTime END)  
							FROM ALP_tblJmTimeCard TC   
							WHERE TC.TicketID = @TicketID AND TC.StartDate   = @NextSchedDate
							AND @NextSchedDate IS NOT NULL  
							GROUP BY  TC.TicketId) 
	SET @tm = (Select CASE WHEN @NextSchedTime = 0 THEN NULL 
			  ELSE CAST(CAST(DATEADD(minute,@NextSchedTime,'2000.01.01') AS TIME) AS VARCHAR(5)) END )     
	return @tm
END