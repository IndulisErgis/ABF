      
CREATE     Procedure [dbo].[ALP_qryAlpEI_ArTransHeader_Insert_sp]      
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
 @ExchRate pDec,  --Added By Sudharson 09/29/2010 -> Added for Foreign Currency      
 @AlpJobNum int,      
 @TaxSubTotal pDec,      
 @TaxSubTotalFgn pDec, --Added By Sudharson 09/08/2010 -> Added for Foreign Currency      
 @NonTaxSubTotal pDec,      
 @NonTaxSubTotalFgn pDec,--Added By Sudharson 09/08/2010 -> Added for Foreign Currency      
 @SalesTax pDec,      
 @SalesTaxFgn pDec, --Added By Sudharson 09/08/2010 -> Added for Foreign Currency      
 @TotPmtAmt pDec,      
 @TotPmtAmtFgn pDec,      
 @AlpFromJobYN bit,      
 @AlpSvcYN bit,      
 @TaxableYn bit,      
       
 @Freight pDec,      
 @FreightFgn pDec, --Added By Sudharson 09/08/2010 -> Added for Foreign Currency      
 @Misc pDec,      
 @MiscFgn pDec,  --Added By Sudharson 09/08/2010 -> Added for Foreign Currency      
 @ClassFreight tinyint,      
 @ClassMisc tinyint,      
 --By Sudharson 07/16/2010 -> Added @DiscDueDate and @NetDueDate      
 @DiscDueDate datetime,      
 @NetDueDate datetime  ,  
 -- By Ravi 10/03/2013 -> Added @SourceId input param  
 @SourceId uniqueidentifier     
AS      
/*   
 Modified on 04.01.2015, Added TaxAdj and TaxLocAdju column along with insert script, added by ravi and MAH   
 Created by Ravi for EFI#1962 on 10/03/2013    
*/      
SET NOCOUNT ON      
INSERT INTO   tblArTransHeader ( TransId, TransType, InvcNum,BatchId, CustId,   InvcDate, CustPoNum,    
         WhseId, GlPeriod,   FiscalYear, TaxGrpID,  Rep1Id, SumHistPeriod, ShipToCountry,    
         OrderDate, ShipDate, PMTransType, ProjItem, BillingFormat, TermsCode, DistCode,      
  CurrencyId,  ExchRate ,    TaxSubTotal, NonTaxSubTotal, SalesTax ,    TaxSubtotalFgn,    
   NonTaxSubtotalFgn, SalesTaxFgn , FreightFgn, MiscFgn,     TaxableYn,Freight,Misc,TaxClassFreight,    
   TaxClassMisc,   DiscDueDate, NetDueDate,SourceId,TaxAdj,TaxLocAdj    )      
VALUES(@TransId,@TransType, @InvcNum, @BatchId , @CustId ,convert(varchar,@InvcDate,101) ,@CustPoNum,     
@WhseId ,@GlPeriod ,   @FiscalYear, @TaxGrpID ,@Rep1Id, @SumHistPeriod,@ShipToCountry,    
@OrderDate ,@ShipDate ,@PMTransType, @ProjItem, @BillingFormat, @TermsCode ,@DistCode ,      
 @CurrencyId, @ExchRate , @TaxSubTotal, @NonTaxSubTotal, @SalesTax,         
 @TaxSubTotalFgn , @NonTaxSubTotalFgn, @SalesTaxFgn , @FreightFgn, @MiscFgn,      
  @TaxableYn,@Freight,@Misc,@ClassFreight,@ClassMisc,      
 @DiscDueDate, @NetDueDate,@SourceId,NULL,@TaxGrpID)      
      
INSERT INTO ALP_tblArTransHeader ( AlpTransId,   AlpSiteId, AlpMailSiteYn,       
  AlpJobNum,    AlpFromJobYN, AlpSvcYN )      
VALUES(@TransId, @AlpSIteId ,@AlpMailSiteYn , @AlpJobNum,          
 @AlpFromJobYN, @AlpSvcYN)