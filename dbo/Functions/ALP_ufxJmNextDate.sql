
CREATE FUNCTION [dbo].[ALP_ufxJmNextDate] 
(
@TicketId Integer
)
RETURNS date 
AS 
-- created by MAH 3/4/16 for Scheduler Jobs List and JM Staging usage
BEGIN
	DECLARE @Today as date 
	DECLARE @NextSchedDate as date
	SET @Today = GetDate() 
	SET @NextSchedDate = NULL
	SET @NextSchedDate =   (SELECT  MIN(CASE WHEN TC.StartDate >= @Today THEN TC.StartDate ELSE NULL END)  
							FROM  dbo.ALP_tblJmTimeCard TC  
							WHERE TC.TicketID = @TicketID  
							GROUP BY TC.TicketId  ) 
   	return @NextSchedDate
END