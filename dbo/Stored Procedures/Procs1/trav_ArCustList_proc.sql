
CREATE PROCEDURE [dbo].[trav_ArCustList_proc]

@SortBy tinyint
--@CustStatus tinyint = 0

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT
		 CASE @SortBy
			WHEN 0 THEN u.CustId 
			WHEN 1 THEN u.SalesRepId1 
			WHEN 2 THEN u.TerrId 
			WHEN 3 THEN u.ClassId 
			WHEN 4 THEN u.DistCode 
			END AS GrpId1, *
	FROM  #tmpCustomerList t INNER JOIN dbo.tblArCust U ON t.CustId = u.CustId   --(NOLOCK)
	--WHERE (@CustStatus=2) OR (@CustStatus=0 AND U.Status=@CustStatus) OR (@CustStatus=1 AND U.Status=@CustStatus)

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustList_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArCustList_proc';

