
CREATE FUNCTION dbo.ufxCS_ZoneLabel_SMS
-- This function returns the label associated with a zone.
-- created 05/03/04 mah
(
	@AccountNumber varchar(36),
	@ZoneID varchar(20),
	@EventType varchar(20) = NULL
)
RETURNS varchar(40)
AS  
BEGIN
DECLARE @ZoneLabel as varchar(40)
DECLARE @ZoneAccount as varchar(40)
set @ZoneLabel = null
set @ZoneAccount = null
set @ZoneLabel = (SELECT Z.[Description]
		FROM SMS...AccountZoneTbl Z
		WHERE(Z.AccountNumber = @AccountNumber)
		AND (Z.ZoneId = @ZoneId)
		AND (Z.EventType = @EventType))
If @ZoneLabel is Null
	BEGIN
	set @ZoneAccount = (SELECT M.ZoneAccount
		FROM SMS...AccountMainTbl M
		WHERE(M.AccountNumber = @AccountNumber))
	Set @ZoneLabel = 
		(SELECT Z.[Description]
		FROM SMS...AccountZoneTbl Z
		WHERE(Z.AccountNumber = @ZoneAccount)
		AND (Z.ZoneId = @ZoneId)
		AND (Z.EventType = @EventType))
	If @ZoneLabel is Null
		BEGIN
		Set @ZoneLabel = ' '
		END
	END
return @ZoneLabel
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_ZoneLabel_SMS] TO PUBLIC
    AS [dbo];

