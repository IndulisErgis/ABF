


CREATE FUNCTION dbo.ufxCS_TestSigs
--EFI# 1396 MAH 04/20/04 - Phoenix Upgrade: table name change
--EFI# 1461 MAH 07/06/04 - Check collect type of Test signals
(
@Transmitter varchar(36)
)
RETURNS varchar(1)
 AS  
BEGIN 
DECLARE @SIGS as varchar(1)
IF EXISTS (
		(SELECT 'TestSIGS'='Y'
		FROM PHX.phoenix.dbo.ABMTransmitter
		WHERE Transmitter_id=@Transmitter
		AND
		Transmitter_id IN
			(
			SELECT Transmitter
--			EFI# 1396 MAH 04/20/04
--			FROM PHX.phoenix.dbo.abmSignal
			FROM PHX.phoenix.dbo.abmSignalHistory
			WHERE signal_id='test'
--				EFI# 1461 MAH 07/06/04 - Check collect type of Test signals
				AND (collect_type IS NOT NULL)
				AND (collect_type NOT IN ('Manual','SystemREM', 'SystemNA',''))
		
		)))
SET @SIGS = 'Y'
else 	
SET @SIGS ='N'
RETURN @SIGS
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_TestSigs] TO PUBLIC
    AS [dbo];

