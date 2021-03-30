       
        
CREATE Procedure [dbo].[ALP_qryCSBS_BSGetActiveTransmitters_sp]
	(  
		@StartTransmitter varchar(36) = '',
	   	@EndTransmitter varchar(36) = 'zzzzzzzzzzzzzzzzzzzzzzzzzzz'
	)
As
SET NOCOUNT ON
	SELECT SS.AlarmId AS Transmitter,
		SS.SysID
	FROM ALP_tblArAlpSiteSys SS
	WHERE  (SS.PulledDate Is Null) 
		AND (SS.AlarmId is not null)
		AND (SS.AlarmID >= @StartTransmitter)
		AND (SS.AlarmID <= @EndTransmitter)
	ORDER BY SS.AlarmId
	return