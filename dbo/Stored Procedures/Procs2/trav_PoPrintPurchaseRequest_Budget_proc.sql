CREATE PROCEDURE [dbo].[trav_PoPrintPurchaseRequest_Budget_proc]
	@TransId pTransId = NULL --set for printing online 
AS
SET NOCOUNT ON;
BEGIN TRY
	
	SELECT TransId, 
		NULLIF(CAST(CF.query(
				'for $i in /ArrayOfEntityPropertyOfString/EntityPropertyOfString
				return
				if (data($i/Name) = "Purchase Approval Budget Year")
				then data($i/Value)
				else ()') As varchar), '') As BudgetYear,
		NULLIF(CAST(CF.query(
				'for $i in /ArrayOfEntityPropertyOfString/EntityPropertyOfString
				return
				if (data($i/Name) = "Purchase Approval Budget Period")
				then data($i/Value)
				else ()') As varchar), '') As BudgetPeriod
	FROM dbo.tblPoTransHeader (NOLOCK)
	WHERE TransId = @TransId

END TRY
BEGIN CATCH
	EXEC dbo.trav_RaiseError_proc
END CATCH
GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPrintPurchaseRequest_Budget_proc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'trav_PoPrintPurchaseRequest_Budget_proc';

