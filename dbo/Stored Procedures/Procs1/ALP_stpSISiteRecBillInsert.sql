CREATE PROCEDURE [dbo].[ALP_stpSISiteRecBillInsert]
(
	-- Updated for TRAV11 by Josh Gillespie on 04/26/2013
	--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 
	@RecBillId INT output,
	@CustId VARCHAR(10) = NULL,
	@SiteId INT = NULL,
	@ContractId INT = NULL,
	@RecBillNum VARCHAR(255) = NULL,
	@ItemId VARCHAR(24) = NULL,
	@Desc VARCHAR(35) = NULL,
	@LocId VARCHAR(10) = NULL,
	@AddnlDesc TEXT = NULL,
	@AcctCode VARCHAR(2) = NULL,
	@GLAcctSales VARCHAR(40) = NULL,
	@GLAcctCOGS VARCHAR(40) = NULL,
	@GLAcctInv VARCHAR(40) = NULL,
	@TaxClass TINYINT = NULL,	
	@CatId VARCHAR(2) = NULL,
	@CustPONum VARCHAR(50) = NULL,
	@CustPODate DATETIME = NULL,
	@NextBillDate DATETIME = NULL,
	@BillCycleId INT = NULL,
	@MailSiteYn bit = NULL,
	@TaxTotal DECIMAL(20,10) = NULL,
	@NonTaxTotal DECIMAL (20, 10) = NULL,
	@SalesTaxTotal DECIMAL (20, 10) = NULL,
	@TaxTotalFgn DECIMAL (20, 10) = NULL,
	@NonTaxTotalFgn DECIMAL (20, 10) = NULL,
	@SalesTaxTotalFgn DECIMAL (20, 10) = NULL,
	@CostTotal DECIMAL (20, 10) = NULL,
	@TaxAmtAdj FLOAT = NULL,
	@TaxAdj TINYINT = NULL,
	@TaxLocAdj VARCHAR(10) = NULL,
	@TaxClassAdj TINYINT = NULL,	
	@ActivePrice DECIMAL (20, 10) = NULL,
	@ActiveCost DECIMAL (20, 10) = NULL,
	@ActiveRMR DECIMAL (20, 10) = NULL,
	@CreateDate DATETIME = NULL,
	@LastUpdateDate DATETIME = NULL,
	@UploadDate DATETIME = NULL,
	@ModifiedBy VARCHAR(50) = NULL,
	@ModifiedDate DATETIME = NULL,
	@UseInvcConsolidationSiteYn BIT = 0,
	@InvcConsolidationSiteId INT = 0
)
AS
	INSERT INTO [dbo].[ALP_tblArAlpSiteRecBill]
		([CustId], [SiteId], [ContractID], [RecBillNum], [ItemId], [Desc], [LocID], [AddnlDesc], [AcctCode],
		 [GLAcctSales], [GLAcctCOGS], [GLAcctInv], [TaxClass], [CatId], [CustPONum], [CustPODate], [NextBillDate],
		 [BillCycleId], [MailSiteYn], [TaxTotal], [NonTaxTotal], [SalesTaxTotal], [TaxTotalFgn], [NonTaxTotalFgn],
		 [SalesTaxTotalFgn], [CostTotal], [TaxAmtAdj], [TaxAdj], [TaxLocAdj], [TaxClassAdj], [ActivePrice], [ActiveCost], [ActiveRMR],
		 [CreateDate], [LastUpdateDate], [UploadDate], [ModifiedBy], [ModifiedDate], [UseInvcConsolidationSiteYn], [InvcConsolidationSiteId])
	VALUES
		(@CustId, @SiteId, @ContractId, @RecBillNum, @ItemId, @Desc, @LocId, @AddnlDesc, @AcctCode, @GLAcctSales,
		 @GLAcctCOGS, @GLAcctInv, @TaxClass, @CatId, @CustPONum, @CustPODate, @NextBillDate, @BillCycleId, @MailSiteYn,
		 @TaxTotal, @NonTaxTotal, @SalesTaxTotal, @TaxTotalFgn, @NonTaxTotalFgn, @SalesTaxTotalFgn, @CostTotal, @TaxAmtAdj,
		 @TaxAdj, @TaxLocAdj, @TaxClassAdj, @ActivePrice, @ActiveCost, @ActiveRMR, @CreateDate, @LastUpdateDate, @UploadDate, @ModifiedBy, @ModifiedDate
		 ,@UseInvcConsolidationSiteYn, @InvcConsolidationSiteId)

	SET @RecBillId = (SELECT @@identity)