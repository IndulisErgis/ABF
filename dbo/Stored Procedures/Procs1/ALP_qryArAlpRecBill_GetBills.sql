
CREATE PROCEDURE [dbo].[ALP_qryArAlpRecBill_GetBills]
(
	@RecBillIds IntegerListType READONLY
)
AS
BEGIN
	SELECT
		[r].[RecBillId],
		[r].[CustId],
		[r].[SiteId],
		[r].[ContractID],
		[r].[RecBillNum],
		[r].[ItemId],
		[r].[Desc],
		[r].[LocID],
		[r].[AddnlDesc],
		[r].[AcctCode],
		[r].[GLAcctSales],
		[r].[GLAcctCOGS],
		[r].[GLAcctInv],
		[r].[TaxClass],
		[r].[CatId],
		[r].[CustPONum],
		[r].[CustPODate],
		[r].[NextBillDate],
		[r].[BillCycleId],
		[r].[MailSiteYN],
		[r].[TaxTotal],
		[r].[NonTaxTotal],
		[r].[SalesTaxTotal],
		[r].[TaxTotalFgn],
		[r].[NonTaxTotalFgn],
		[r].[SalesTaxTotalFgn],
		[r].[CostTotal],
		[r].[TaxAmtAdj],
		[r].[TaxAdj],
		[r].[TaxLocAdj],
		[r].[TaxClassAdj],
		[r].[ActivePrice],
		[r].[ActiveCost],
		[r].[ActiveRMR],
		[r].[CreateDate],
		[r].[LastUpdateDate],
		[r].[UploadDate],
		[r].[ts],
		[r].[ModifiedBy],
		[r].[ModifiedDate],
		[r].[UseInvcConsolidationSiteYn],
		[r].[InvcConsolidationSiteId]
	FROM	[dbo].[ALP_tblArAlpSiteRecBill] AS [r]
	INNER JOIN @RecBillIds AS [input]
		ON	[input].[Id] = [r].[RecBillId]
END