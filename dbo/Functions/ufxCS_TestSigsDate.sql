
CREATE   FUNCTION dbo.ufxCS_TestSigsDate
/* created:
	EFI# ???? MAH 05/13/04
    Modified:
        EFI# 1461 MAH 07/06/04 - Refine determination of 'test' signals.  Check receiver type. ingnore manual tests.
	EFI# xxxx MAH 05/10/06 - Change determination of 'test' signals.  Use sigcat rather than signal_id
	EFI# 1725 MAH 04/21/07 - Limit search to test sigs on or after @EarliestDate
*/
(
@Transmitter varchar(36),
@EarliestDate datetime = null
)
RETURNS TABLE
AS
RETURN(
	SELECT
	FirstTestSignal=min(signal_date)
	--EFI# 1396 MAH 042004
	FROM PHX.phoenix.dbo.ABMSignalHistory
	--FROM PHX.phoenix.dbo.ABMSignal
	WHERE (transmitter = @Transmitter) 
		AND (@EarliestDate IS NULL OR signal_date >= @EarliestDate)
		AND (sigcat = 4)
		AND (collect_type IS NOT NULL)
		AND (collect_type NOT IN ('Manual','SystemREM', 'SystemNA',''))
	--WHERE (transmitter = @Transmitter) 
		--AND (signal_id = 'test')
		--AND (collect_type IS NOT NULL)
		--AND (collect_type NOT IN ('Manual','SystemREM', 'SystemNA',''))
)
GO
GRANT SELECT
    ON OBJECT::[dbo].[ufxCS_TestSigsDate] TO PUBLIC
    AS [dbo];

