
CREATE FUNCTION dbo.ufxCS_HasSignalsYN
/* Modified:
	EFI# 1382 MAH 033104 - changed collect_type filter used to distinguish a 'live' signal
	EFI# 1396 MAH 042004 - Phoenix upgrade; table name change
	EFI# 1431 MAH 051004 - added FirstSignal Date to output
*/
(
@Transmitter varchar(36)
)
RETURNS TABLE
AS
RETURN(
	SELECT
	SignalsYN = 
		case 
			when max(signal_date) is null
			then 'N'
			else 'Y'
		end,
	LastSignal=max(signal_date),
--   	EFI# 1431 MAH 05/10/04 - added item FirstSignalDate
	FirstSignal=min(signal_date)
--EFI# 1396 MAH 042004
FROM PHX.phoenix.dbo.ABMSignalHistory
--FROM PHX.phoenix.dbo.ABMSignal
WHERE (transmitter = @Transmitter) 
	AND (collect_type IS NOT NULL)
	AND (collect_type NOT IN ('Manual','SystemREM', 'SystemNA','')))
--WHERE collect_type = 'SURGARD'
--	AND transmitter = @Transmitter)
GO
GRANT SELECT
    ON OBJECT::[dbo].[ufxCS_HasSignalsYN] TO PUBLIC
    AS [dbo];

