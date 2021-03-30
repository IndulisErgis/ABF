
CREATE PROCEDURE [dbo].[ALP_qrySISiteRecBillGetBySiteId]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	@SiteId int
)
AS
BEGIN
	SELECT
		[srb].[RecBillId],
		[srb].[CustId],
		[srb].[SiteId],
		[srb].[ContractID],
		[srb].[RecBillNum],
		[srb].[ItemId],
		[srb].[Desc],
		[srb].[LocID],
		[srb].[AddnlDesc],
		[srb].[AcctCode],
		[srb].[GLAcctSales],
		[srb].[GLAcctCOGS],
		[srb].[GLAcctInv],
		[srb].[TaxClass],
		[srb].[CatId],
		[srb].[CustPONum],
		[srb].[CustPODate],
		[srb].[NextBillDate],
		[srb].[BillCycleId],
		[srb].[MailSiteYN],
		[srb].[TaxTotal],
		[srb].[NonTaxTotal],
		[srb].[SalesTaxTotal],
		[srb].[TaxTotalFgn],
		[srb].[NonTaxTotalFgn],
		[srb].[SalesTaxTotalFgn],
		[srb].[CostTotal],
		[srb].[TaxAmtAdj],
		[srb].[TaxAdj],
		[srb].[TaxLocAdj],
		[srb].[TaxClassAdj],
		[srb].[ActivePrice],
		[srb].[ActiveCost],
		[srb].[ActiveRMR],
		[srb].[CreateDate],
		[srb].[LastUpdateDate],
		[srb].[UploadDate],
		[srb].[ts],
		[srb].[ModifiedBy],
		[srb].[ModifiedDate],
		[srb].[UseInvcConsolidationSiteYn],
		[srb].[InvcConsolidationSiteId]
	FROM [dbo].[ALP_tblArAlpSiteRecBill_view] AS [srb] 
	WHERE [srb].[SiteId] = @SiteId
END