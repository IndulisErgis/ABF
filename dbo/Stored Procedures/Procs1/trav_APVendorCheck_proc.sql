
CREATE PROCEDURE [dbo].[trav_APVendorCheck_proc]
	@VendorId pVendorId	
AS

SET NOCOUNT ON

BEGIN TRY
	
	DECLARE @Count pDecimal
	
	SELECT @Count = COUNT(*)
		FROM dbo.tblApPrepchkCheck (NOLOCK)
		WHERE VendorId = @VendorId

	SELECT @Count AS CountOf
		
END TRY
BEGIN CATCH
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_APVendorCheck_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_APVendorCheck_proc';

