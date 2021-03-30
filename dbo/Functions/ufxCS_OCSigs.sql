CREATE FUNCTION DBO.ufxCS_OCSigs
--EFI# 1396 MAH 04/20/04 - Phoenix upgrade: table name change
(
@Transmitter varchar(36)
)
RETURNS varchar(1)
 AS  
BEGIN 
DECLARE @SIGS as varchar(1)
IF EXISTS (
		SELECT 'OCSIGS'='Y'
		FROM PHX.phoenix.dbo.ABMTransmitter
		WHERE Transmitter_id=@Transmitter
		AND
		Transmitter_id IN
			(
			SELECT Transmitter
--			EFI# 1396 MAH 04/20/04
--			FROM PHX.phoenix.dbo.abmSignal
			FROM PHX.phoenix.dbo.abmSignalHistory
			WHERE signal_id like 'open%'
			)
		AND
		Transmitter_id IN
			(
			SELECT Transmitter
--			EFI# 1396 MAH 04/20/04
--			FROM PHX.phoenix.dbo.abmSignal
			FROM PHX.phoenix.dbo.abmSignalHistory
			WHERE signal_id like 'clos%'
			)
		)
SET @SIGS = 'Y'
else 	
SET @SIGS ='N'
RETURN @SIGS
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_OCSigs] TO PUBLIC
    AS [dbo];

