
CREATE FUNCTION dbo.ufxCS_ZoneLabel
-- This function returns the label associated with a zone.
-- created 11/24/03 mah
(
	@transmitter varchar(36),
	@zone varchar(7),
	@signal_id varchar(20) = NULL
)
RETURNS varchar(40)
AS  
BEGIN
DECLARE @ZoneLabel as varchar(40)
set @ZoneLabel = null
set @ZoneLabel = (SELECT Z.label 
		FROM PHX.phoenix.dbo.ABMzone Z
		WHERE(Z.transmitter = @transmitter)
		AND (Z.zone_id = @zone)
		AND (Z.sigtype = @signal_id))
If @ZoneLabel is Null
	BEGIN
	Set @ZoneLabel = (SELECT Z.label 
		FROM PHX.phoenix.dbo.ABMzone Z
		WHERE(Z.transmitter = @transmitter)
		AND (Z.zone_id = @zone)
		AND (Z.sigtype = '-1'))
	If @ZoneLabel is Null
		BEGIN
		Set @ZoneLabel = ' '
		END
	END
return @ZoneLabel
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ufxCS_ZoneLabel] TO PUBLIC
    AS [dbo];

