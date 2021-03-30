CREATE FUNCTION dbo.ufxCS_SiteIDNameAndAddr
--EFI# 1652 MAH 05/15/06 - use site ID stored in hardrevision field
(
@transmitter varchar(36) 
)
RETURNS TABLE
AS
RETURN(
SELECT site_name,hardrevision as site,address1
	FROM PHX.phoenix.dbo.ABMTransmitter
	WHERE transmitter_id=@transmitter)
GO
GRANT SELECT
    ON OBJECT::[dbo].[ufxCS_SiteIDNameAndAddr] TO PUBLIC
    AS [dbo];

