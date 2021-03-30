
CREATE FUNCTION [dbo].[ALP_ufxConvertToTimeFormat] 
(
-- MAH 05/12/14 - convert the start or end times found in TimeCards to standard time format (HH:MM)
@TimeCardTime Integer
)
RETURNS varchar(5) 
AS  
BEGIN 
	DECLARE @result varchar(5)
	DECLARE @tmpHr varchar(2)
	DECLARE @tmpMin varchar(2)
	SET @result = '00:00'
	SET @tmpHr = CAST((@TimeCardTime/60) as varchar(2)) 
	SET @tmpMin = CAST((@TimeCardTime % 60) as varchar(2)) 
	SET @result = CASE WHEN LEN(@tmpHr) < 2 THEN '0' + @tmpHr
					ELSE @tmpHr END + ':' + 
			  CASE WHEN LEN(@tmpMin) < 2 THEN '0' + @tmpMin
					ELSE @tmpMin END
	return @result	
END