CREATE function [dbo].[ufxJm_GetSvcTktTech]
(
	@TicketID int
)
returns varchar(10)
AS
--created 07/29/11 MAH
--10/22/11 MAH corrected SQL to select lead tech if job not yet on schedule
BEGIN
declare @TechID int 
declare @TechName varchar(10)
declare @FirstStartDate datetime
SET @TechID = null
SET @TechName = ''
SET @FirstStartDate = null

SET @FirstStartDate = 
		(SELECT min(StartDate)  
	   	FROM dbo.tblJmTimecard TC
	   	WHERE  TC.TicketID = @TicketID
		)

IF @FirstStartDate is null
BEGIN
	SET @TechName = 
		(SELECT distinct T.Tech   
	   	FROM dbo.tblJmSvcTkt ST INNER JOIN dbo.tblJmTech T ON ST.LeadTechID = T.TechID
	   	WHERE  ST.TicketID = @TicketID)
END
ELSE
BEGIN
	SET @TechID = 
		(SELECT MIN(TC.TechID)  
	   	FROM dbo.tblJmTimecard TC
	   	WHERE  TC.TicketID = @TicketID
		AND  TC.StartDate = @FirstStartDate
		GROUP BY TC.TicketID, TC.StartDate)
	SET @TechName = 
		(SELECT T.Tech   
	   	FROM dbo.tblJmTech T 
	   	WHERE  T.TechID = @TechID)

END
RETURN @TechName
END