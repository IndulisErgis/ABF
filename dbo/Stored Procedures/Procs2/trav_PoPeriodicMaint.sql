
CREATE PROCEDURE dbo.trav_PoPeriodicMaint 
@DateDocLink datetime = NULL

AS
SET NOCOUNT ON
BEGIN TRY

	-- Delete Document links that have expired
	IF (@DateDocLink IS NOT NULL)
	BEGIN

		--purge expired document links
		DELETE dbo.tblSMDocLink
		WHERE [ExpireDate] < @DateDocLink AND SourceType = 128 --limit data to PO source types
	END

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPeriodicMaint';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPeriodicMaint';

