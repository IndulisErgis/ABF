
CREATE PROCEDURE dbo.ALP_qryUpdateTimeBar
@dStartDate datetime, @dEndDate datetime, @iStartTime int, @iEndTime int,@iTechID int, @sTimeCardComment varchar(500),@iTimeCardID int
As
SET NOCOUNT ON
UPDATE ALP_tblJmTimeCard 
SET StartDate = @dStartDate, EndDate =@dEndDate, StartTime = @iStartTime, 
	EndTime =@iEndTime, TechID= @iTechID, TimeCardComment=@sTimeCardComment	
WHERE TimeCardID = @iTimeCardID