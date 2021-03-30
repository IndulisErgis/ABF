
CREATE PROCEDURE [dbo].[trav_SmDescriptionItemReport_proc]

AS
SET NOCOUNT ON
BEGIN TRY

	SELECT i.ItemCode, [Desc] AS [Description], GLAcctExp AS GlAccountExpense, GLAcctSales AS GlAccountSales
		, GLAcctCogs AS GlAccountCogs, GLAcctInv AS GlAccountInventory, TaxClass
		, Units, UnitCost, UnitPrice, AddnlDesc 
	FROM dbo.tblSmItem i INNER JOIN #tmpItemList t ON i.ItemCode = t.ItemCode

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmDescriptionItemReport_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_SmDescriptionItemReport_proc';

