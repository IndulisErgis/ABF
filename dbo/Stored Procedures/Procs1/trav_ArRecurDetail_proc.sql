
CREATE PROCEDURE dbo.trav_ArRecurDetail_proc
@RecurId nvarchar (8)
AS
BEGIN TRY
	SET NOCOUNT ON

	SELECT ItemId, Descr, AddnlDescr, LocId, TaxClass, Quantity, Units, AcctCode
		, GLAcctSales, GLAcctCOGS, GLAcctInv, CatId, PriceId, UnitCost, UnitPrice
		, CAST(UnitCost * Quantity AS float) AS ExtCost, CAST(UnitPrice * Quantity AS float) AS ExtPrice,CustomerPartNumber 
	FROM dbo.tblArRecurDetail WHERE RecurId = @RecurId ORDER BY LineSeq

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArRecurDetail_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_ArRecurDetail_proc';

