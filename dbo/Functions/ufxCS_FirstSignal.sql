CREATE FUNCTION dbo.ufxCS_FirstSignal
/* mah 12/15/08  */
(
@Transmitter varchar(36)
)
returns datetime
AS
BEGIN
declare @FirstSignal datetime
SET @FirstSignal = null
BEGIN
	SET @FirstSignal = 
	       (SELECT	FirstSignal=min(signal_date)
		FROM PHX.phoenix.dbo.ABMSignalHistory
		WHERE (transmitter = @Transmitter) 
		AND (collect_type IS NOT NULL)
		AND (collect_type NOT IN ('Manual','SystemREM', 'SystemNA','')))
END
RETURN @FirstSignal
END