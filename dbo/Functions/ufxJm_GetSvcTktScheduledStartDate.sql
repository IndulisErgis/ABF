CREATE function [dbo].[ufxJm_GetSvcTktScheduledStartDate]
(
	@TicketID int
)
returns varchar(10)
AS
--created 10/22/11 MAH
BEGIN
declare @FirstStartDate datetime
declare @FirstStartDateStr varchar(10)
SET @FirstStartDate = null
SET @FirstStartDateStr = ''

SET @FirstStartDate = 
		(SELECT min(StartDate)  
	   	FROM dbo.tblJmTimecard TC
	   	WHERE  TC.TicketID = @TicketID
		AND StartDate > GetDate()
		)

IF @FirstStartDate is null
BEGIN
	SET @FirstStartDateStr = '' 
END
Else
BEGIN
	SET @FirstStartDateStr = CONVERT(Varchar(10),@FirstStartDate,101)
END

RETURN @FirstStartDateStr
END