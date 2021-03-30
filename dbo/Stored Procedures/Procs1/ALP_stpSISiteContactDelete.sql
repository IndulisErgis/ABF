CREATE PROCEDURE [dbo].[ALP_stpSISiteContactDelete]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/30/2013
	@ContactID INT
)
AS
BEGIN
	DELETE FROM [dbo].[ALP_tblArAlpSiteContact]
	WHERE	[ContactID] = @ContactID
	RETURN 0
END