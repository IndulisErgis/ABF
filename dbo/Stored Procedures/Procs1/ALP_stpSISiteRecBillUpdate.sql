﻿CREATE PROCEDURE [dbo].[ALP_stpSISiteRecBillUpdate]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	@RecBillId int,
	@CustId varchar(10) = null,
	@SiteId int = null,
	@ContractId int = null,
	@RecBillNum varchar(255) = null,
	@ItemId varchar(24) = null,
	@Desc varchar(35) = null,
	@LocId varchar(10) = null,
	@AddnlDesc text = null,
	@AcctCode varchar(2) = null,
	@GLAcctSales varchar(40) = null,
	@GLAcctCOGS varchar(40) = null,
	@GLAcctInv varchar(40) = null,
	@TaxClass tinyint = null,
	@CatId varchar(2) = null,
	@CustPONum varchar(50) = null,
	@CustPODate datetime = null,
	@NextBillDate datetime = null,
	@BillCycleId int = null,
	@MailSiteYn bit = null,
	@TaxTotal decimal(20,10) = null,
	@NonTaxTotal decimal (20, 10) = null,
	@SalesTaxTotal decimal (20, 10) = null,
	@TaxTotalFgn decimal (20, 10) = null,
	@NonTaxTotalFgn decimal (20, 10) = null,
	@SalesTaxTotalFgn decimal (20, 10) = null,
	@CostTotal decimal (20, 10) = null,
	@TaxAmtAdj float = null,
	@TaxAdj tinyint = null,
	@TaxLocAdj varchar(10) = null,
	@TaxClassAdj tinyint = null,
	@ActivePrice decimal (20, 10) = null,
	@ActiveCost decimal (20, 10) = null,
	@ActiveRMR decimal (20, 10) = null,
	@CreateDate datetime = null,
	@LastUpdateDate datetime = null,
	@UploadDate datetime = null,
	@ModifiedBy VARCHAR(50) = NULL,
	@ModifiedDate DATETIME = NULL,
	@UseInvcConsolidationSiteYn BIT = 0,
	@InvcConsolidationSiteId INT = 0
)
AS
BEGIN
	UPDATE [srb]
	SET	[srb].[CustId]  = @CustId,
		[srb].[SiteId]  = @SiteId,
		[srb].[ContractID]  = @ContractId,
		[srb].[RecBillNum]  = @RecBillNum,
		[srb].[ItemId]  = @ItemId,
		[srb].[Desc]  = @Desc,
		[srb].[LocID]  = @LocId,
		[srb].[AddnlDesc]  = @AddnlDesc,
		[srb].[AcctCode]  = @AcctCode,
		[srb].[GLAcctSales]  = @GLAcctSales,
		[srb].[GLAcctCOGS]  = @GLAcctCOGS,
		[srb].[GLAcctInv]  = @GLAcctInv,
		[srb].[TaxClass]  = @TaxClass,
		[srb].[CatId]  = @CatId,
		[srb].[CustPONum]  = @CustPONum,
		[srb].[CustPODate]  = @CustPODate,
		[srb].[NextBillDate]  = @NextBillDate,
		[srb].[BillCycleId]  = @BillCycleId,
		[srb].[MailSiteYN]  = @MailSiteYn,
		[srb].[TaxTotal]  = @TaxTotal,
		[srb].[NonTaxTotal]  = @NonTaxTotal,
		[srb].[SalesTaxTotal]  = @SalesTaxTotal,
		[srb].[TaxTotalFgn]  = @TaxTotalFgn,
		[srb].[NonTaxTotalFgn]  = @NonTaxTotalFgn,
		[srb].[SalesTaxTotalFgn]  = @SalesTaxTotalFgn,
		[srb].[CostTotal]  = @CostTotal,
		[srb].[TaxAmtAdj]  = @TaxAmtAdj,
		[srb].[TaxAdj]  = @TaxAdj,
		[srb].[TaxLocAdj]  = @TaxLocAdj,
		[srb].[TaxClassAdj] = @TaxClassAdj,
		[srb].[ActivePrice]  = @ActivePrice,
		[srb].[ActiveCost]  = @ActiveCost,
		[srb].[ActiveRMR]  = @ActiveRMR,
		[srb].[CreateDate]  = @CreateDate,
		[srb].[LastUpdateDate]  = @LastUpdateDate,
		[srb].[UploadDate]  = @UploadDate,
		[srb].[ModifiedBy] = @ModifiedBy,
		[srb].[ModifiedDate] = @ModifiedDate,
		[srb].[UseInvcConsolidationSiteYn] = @UseInvcConsolidationSiteYn,
		[srb].[InvcConsolidationSiteId] = @InvcConsolidationSiteId
	FROM [dbo].[ALP_tblArAlpSiteRecBill] AS [srb]
	WHERE	[srb].[RecBillId] = @RecBillId
END