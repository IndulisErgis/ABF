

CREATE FUNCTION [dbo].[ALP_ufxConvertToTimeFormat2] 
(
-- MAH  - convert the start or end times found in TimeCards to standard time format (HH:MM) using AM or PM
@TimeCardTime Integer
)
RETURNS varchar(8) 
AS  
BEGIN 
	DECLARE @result varchar(8)
	DECLARE @tmpHr varchar(2)
	DECLARE @tmpMin varchar(2)
	DECLARE @AMPM as varchar(3)
	SET @AMPM = ' AM'
	SET @result = '00:00'
	SET @tmpHr = CAST((@TimeCardTime/60) as varchar(2)) 
	SET @tmpMin = CAST((@TimeCardTime % 60) as varchar(2)) 
	SET @AMPM = CASE WHEN @tmpHr >= 12 THEN ' PM' ELSE  ' AM' END
	SET @tmpHr = CASE WHEN @tmpHr > 12 THEN @tmpHr - 12 ELSE @tmpHr END
	SET @result = CASE WHEN LEN(@tmpHr) < 2 THEN '0' + @tmpHr
					ELSE @tmpHr END + ':' + 
			  CASE WHEN LEN(@tmpMin) < 2 THEN '0' + @tmpMin
					ELSE @tmpMin END + @AMPM
	--SET @result = CASE WHEN LEN(@tmpHr) < 2 THEN '0' + @tmpHr
	--				ELSE @tmpHr END + ':' + 
	--		  CASE WHEN LEN(@tmpMin) < 2 THEN '0' + @tmpMin
	--				ELSE @tmpMin END
	return @result	
END