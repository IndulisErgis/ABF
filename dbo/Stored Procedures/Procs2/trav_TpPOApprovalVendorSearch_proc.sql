
CREATE PROCEDURE [dbo].[trav_TpPOApprovalVendorSearch_proc]
@SearchText nvarchar(500),
@CurrId pCurrency,
@MaxCount int = 100
AS
SET NOCOUNT ON
BEGIN TRY
	SELECT [VendorID], [Name], [Contact], [City], [Region], [PostalCode], [Status] FROM (
		SELECT TOP (@MaxCount) * FROM [dbo].[tblApVendor]
			WHERE [Status] = 0 AND ([VendorID] LIKE @SearchText+'%' OR [Name] LIKE '%'+@SearchText+'%' OR [Contact] LIKE '%'+@SearchText+'%'
			OR [City] LIKE @SearchText+'%' OR [Region] LIKE @SearchText+'%' OR [PostalCode] LIKE @SearchText+'%')
			AND CurrencyId = @CurrId) c
		ORDER BY VendorID
END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TpPOApprovalVendorSearch_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_TpPOApprovalVendorSearch_proc';

