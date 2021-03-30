CREATE FUNCTION dbo.ufxCS_OnLineDate
(
@transmitter varchar(36)
)
RETURNS TABLE
AS  
RETURN(
	SELECT 
		installdate
	FROM PHX.phoenix.dbo.ABMTransmitter
	WHERE transmitter_id=@transmitter)
GO
GRANT SELECT
    ON OBJECT::[dbo].[ufxCS_OnLineDate] TO PUBLIC
    AS [dbo];

