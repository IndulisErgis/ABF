CREATE Procedure dbo.Alp_qryArAlpAppendTransHeader_CancelServices  
@TransId pTransId,  
@TransType smallint,  
@InvcNum pInvoiceNum,  
@BatchId pBatchId,  
@CustId pCustId,  
@AlpSiteId int,  
@AlpMailSiteYn bit,  
@InvcDate datetime,  
@WhseId pLocId,  
@GlPeriod smallint,  
@FiscalYear smallint,  
@TaxGrpID pTaxLoc,  
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
@Rep1Id pSalesRep = null,  
@Rep1Pct pDec,  
@Rep2Id pSalesRep = null,  
@Rep2Pct pDec  
AS  
SET NOCOUNT ON  
INSERT INTO tblArTransHeader ( TransId, TransType, InvcNum,BatchId, CustId,   InvcDate, WhseId, GlPeriod,  
 FiscalYear, TaxGrpID,  SumHistPeriod, ShipToCountry, OrderDate, ShipDate, PMTransType, ProjItem, BillingFormat, TermsCode, DistCode,  
 CurrencyId,  Rep1Id, Rep1Pct, Rep2Id, Rep2Pct )  
VALUES(@TransId,@TransType, @InvcNum, @BatchId , @CustId  ,@InvcDate ,@WhseId ,@GlPeriod ,  
 @FiscalYear ,@TaxGrpID ,@SumHistPeriod,@ShipToCountry,@OrderDate ,@ShipDate ,@PMTransType, @ProjItem, @BillingFormat, @TermsCode ,@DistCode ,  
 @CurrencyId ,@Rep1Id ,@Rep1Pct ,@Rep2Id ,@Rep2Pct )
 
 INSERT INTO Alp_tblArTransHeader ( AlpTransId,AlpSiteId, AlpMailSiteYn )  
VALUES(@TransId, @AlpSIteId ,@AlpMailSiteYn  )