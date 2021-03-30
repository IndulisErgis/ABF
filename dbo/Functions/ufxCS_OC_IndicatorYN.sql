CREATE FUNCTION dbo.ufxCS_OC_IndicatorYN
(
@Transmitter varchar(36)
)
RETURNS varchar(1)
AS
BEGIN
return(SELECT OC_Indicator =
	open_close_indicator
	FROM PHX.phoenix.dbo.ABMTransmitter
	WHERE transmitter_id = @Transmitter)
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_OC_IndicatorYN] TO PUBLIC
    AS [dbo];

