

/* EFI 1368 JAL 03/26/04 Pass site's TaxableYn to transaction hearder */
CREATE Procedure dbo.ALP_qryJmSvcTktAppendTransHeader
@TransId pTransId,
@TransType smallint,
@InvcNum pInvoiceNum,
@BatchId pBatchId,
@CustId pCustId,
@AlpSiteId int,
@AlpMailSiteYn bit,
@InvcDate datetime,
@CustPoNum varchar(25),
@WhseId pLocId,
@GlPeriod smallint,
@FiscalYear smallint,
@TaxGrpID pTaxLoc,
@Rep1Id pSalesRep,
@SumHistPeriod smallint,
@ShipToCountry pCountry,
@OrderDate datetime,
@ShipDate datetime,
@PMTransType varchar(4),
@ProjItem varchar(4),
@BillingFormat smallint,
@TermsCode pTermsCode,
@DistCode pDistCode,
@CurrencyId pCurrency,
@AlpJobNum int,
@NonTaxSubTotal pDec,
@TotPmtAmt pDec,
@TotPmtAmtFgn pDec,
@AlpFromJobYN bit,
@AlpSvcYN bit,
@TaxableYn bit
AS
SET NOCOUNT ON
BEGIN TRY
BEGIN TRAN
INSERT INTO tblArTransHeader ( TransId, TransType, InvcNum,BatchId, CustId,  InvcDate, CustPoNum, WhseId, GlPeriod,
	FiscalYear, TaxGrpID,  Rep1Id, SumHistPeriod, ShipToCountry, OrderDate, ShipDate, PMTransType, ProjItem, BillingFormat, TermsCode, DistCode,
	CurrencyId,  NonTaxSubTotal,  TaxableYn )
VALUES(@TransId,@TransType, @InvcNum, @BatchId , @CustId ,@InvcDate ,@CustPoNum, @WhseId ,@GlPeriod ,
	@FiscalYear ,@TaxGrpID ,@Rep1Id, @SumHistPeriod,@ShipToCountry,@OrderDate ,@ShipDate ,@PMTransType, @ProjItem, @BillingFormat, @TermsCode ,@DistCode ,
	@CurrencyId , @NonTaxSubTotal,  @TaxableYn )
	
	INSERT into ALP_tblArTransHeader(AlpSiteId, AlpMailSiteYn, AlpJobNum, AlpFromJobYN, AlpSvcYN)
	Values (@AlpSIteId ,@AlpMailSiteYn ,@AlpJobNum, @AlpFromJobYN, @AlpSvcYN)
Commit

END TRY
BEGIN CATCH
ROLLBACK
END CATCH