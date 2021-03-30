
CREATE PROCEDURE  [dbo].[trav_ApVendorList_proc]

@PrintBy tinyint
--@Status tinyint  --status can be part of filter

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT 	CASE @PrintBy
			WHEN 0 THEN v.VendorID
			WHEN 1 THEN v.DivisionCode
			WHEN 2 THEN v.VendorClass
			WHEN 3 THEN v.DistCode
			END AS GrpId1, *
	FROM dbo.tblApVendor v INNER JOIN #tmpVendorList t ON v.VendorID = t.VendorID
	--WHERE v.Status = @Status OR @Status = 2

	SELECT * FROM dbo.tblApVendor a INNER JOIN #tmpVendorList t ON a.VendorID = t.VendorID

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ApVendorList_proc';

