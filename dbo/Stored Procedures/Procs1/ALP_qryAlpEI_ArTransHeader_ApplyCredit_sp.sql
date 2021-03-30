CREATE       procedure [dbo].[ALP_qryAlpEI_ArTransHeader_ApplyCredit_sp]   
--Below param @UnAppldSiteId Default value assigned 0, modified by Ravi on 06.24.2015 
--mah 03/05/14: assigned AlpFromJob = 0 to identify the crediting (reversing) entries  
-- from the original invoice being credited. ( note: AlpJobNumber must be   
-- assigned the same to all entries created, so that invoice deletes clean out   
-- these records as well as invoice itself )  
--changed by mah 04/03/2014:   
 @OldTransID varchar(8),    
 @NewTransID1 varchar(8),    
 @NewTransID2 varchar(8),    
 @SiteID  int,    
 @UnAppldSiteID  int=0,    
 @AmtToApply decimal(20,10),    
 @AmtToApplyFgn decimal(20,10), --By Sudharson 09/09/2010 - Added @AmtToApplyFgn parameter    
        @CurrencyID  pCurrency, --By Sudharson 09/29/2010 - Added @CurrencyID parameter    
 @ExchRate  pDec,    --By Sudharson 09/29/2010 - Added @ExchRate parameter    
 @InvcNum pInvoiceNum,    
 @UnAppldInvcNum pInvoiceNum,    
 @AlpJobNum int --By Sudharson 07/07/2010 - Added @AlpJobNum parameter    
As    
Begin     
INSERT INTO tblArTransHeader    
 (    
  TransId, TransType, BatchId, CustId,    
  ShipToID, ShipToName, ShipToAddr1, ShipToAddr2,    
  ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode,    
  ShipVia, TermsCode, TaxableYN, InvcNum,    
  WhseId,  OrderDate, ShipNum, ShipDate,    
  InvcDate, Rep1Id,  Rep1Pct, Rep2Id,    
  Rep2Pct, TaxOnFreight, TaxClassFreight,TaxClassMisc,    
  PostDate, GLPeriod, FiscalYear, TaxGrpID,    
  TaxSubtotal, NonTaxSubtotal, SalesTax, Freight,    
  Misc,  TotCost , TaxSubtotalFgn,    
  NonTaxSubtotalFgn,SalesTaxFgn, FreightFgn, MiscFgn,    
  TotCostFgn , PrintStatus, CustPONum,    
  DistCode, CurrencyID, ExchRate, DiscDueDate,    
  NetDueDate, DiscAmt, SumHistPeriod, TaxAmtAdj,    
  TaxAmtAdjFgn, TaxAdj,  TaxLocAdj, TaxClassAdj,    
  BillingPeriodFrom,PMTransType, ProjItem, BillingPeriodThru,    
  BillingFormat    ,SourceId ,VoidYn   
 )    
      
 Select     
  @NewTransID1, TransType, BatchId, CustId,    
  ShipToID, ShipToName, ShipToAddr1, ShipToAddr2,    
  ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode,    
  ShipVia, TermsCode, TaxableYN, @InvcNum,    
  WhseId,  OrderDate, ShipNum, ShipDate,    
  InvcDate, Rep1Id,  Rep1Pct, Rep2Id,    
  Rep2Pct, TaxOnFreight, TaxClassFreight,TaxClassMisc,    
  PostDate, GLPeriod, FiscalYear, TaxGrpID,    
  0, @AmtToApply, 0,  0,    
  0,  @AmtToApply,  0,  --@AmtToApplyFgn,  --changed by mah 04/03/2014 - amount to apply had been entered into too many places - taxable and nontaxable both  
  @AmtToApplyFgn, 0,  0,  0,    
  --@AmtToApplyFgn, @AmtToApplyFgn, 0,  CustPONum,    
  0,   0,  CustPONum, --changed by mah 03/07/13 - corrected incorrect amounts going into TotCost and TotPmt fields    
  DistCode, @CurrencyID, @ExchRate, DiscDueDate,    
  NetDueDate, 0,  SumHistPeriod, 0,    
  0,  0,  0,  0,    
  BillingPeriodFrom,PMTransType, ProjItem, BillingPeriodThru,    
  BillingFormat  ,SourceId ,VoidYn   
 from  tblArTransHeader    
 Where  TransID = @OldTransID     
    
  INSERT INTO ALP_tblArTransHeader    
 (    
  ALPTransId,    AlpSiteID, AlpMailSiteYN, AlpJobNum,      
  AlpRep1AmtYn, AlpRep2AmtYn, AlpFromJobYN, AlpSvcYN,      
  AlpRecBillRef, AlpSendToPrintYn,AlpUploadDate, AlpJobNumRmr,      
  AlpSubscriberInvcYn    
 )    
 Select @NewTransID1,    @SiteID, AlpMailSiteYN, @AlpJobNum,      
  AlpRep1AmtYn, AlpRep2AmtYn,   
  0, --AlpFromJobYN,   
  AlpSvcYN,      
  AlpRecBillRef, AlpSendToPrintYn,AlpUploadDate, AlpJobNumRmr,      
  AlpSubscriberInvcYn  From ALP_tblArTransHeader  where AlpTransId = @OldTransID   
    
    
INSERT INTO tblArTransHeader    
 (    
  TransId, TransType, BatchId, CustId,    
  ShipToID, ShipToName, ShipToAddr1, ShipToAddr2,    
  ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode,    
  ShipVia, TermsCode, TaxableYN, InvcNum,    
  WhseId,  OrderDate, ShipNum, ShipDate,    
  InvcDate, Rep1Id,  Rep1Pct, Rep2Id,    
  Rep2Pct, TaxOnFreight, TaxClassFreight,TaxClassMisc,    
  PostDate, GLPeriod, FiscalYear, TaxGrpID,    
  TaxSubtotal, NonTaxSubtotal, SalesTax, Freight,    
  Misc,  TotCost,  TaxSubtotalFgn,    
  NonTaxSubtotalFgn,SalesTaxFgn, FreightFgn, MiscFgn,    
  TotCostFgn, PrintStatus, CustPONum,    
  DistCode, CurrencyID, ExchRate, DiscDueDate,    
  NetDueDate, DiscAmt, SumHistPeriod, TaxAmtAdj,    
  TaxAmtAdjFgn, TaxAdj,  TaxLocAdj, TaxClassAdj,    
  BillingPeriodFrom,PMTransType, ProjItem, BillingPeriodThru,    
  BillingFormat  ,SourceId ,VoidYn   
 )    
      
 Select     --@NewTransID, TransType, BatchId, CustId,    
  @NewTransID2, TransType, BatchId, CustId,    
  ShipToID, ShipToName, ShipToAddr1, ShipToAddr2,    
  ShipToCity, ShipToRegion, ShipToCountry, ShipToPostalCode,    
  ShipVia, TermsCode, TaxableYN, @UnAppldInvcNum,    
  WhseId,  OrderDate, ShipNum, ShipDate,    
  InvcDate, Rep1Id,  Rep1Pct, Rep2Id,    
  Rep2Pct, TaxOnFreight, TaxClassFreight,TaxClassMisc,    
  PostDate, GLPeriod, FiscalYear, TaxGrpID,    
  TaxSubtotal*-1, @AmtToApply*-1, 0,  0,    
  0,  @AmtToApply*-1,   @AmtToApplyFgn*-1,    
  @AmtToApplyFgn*-1, 0,  0,  0,    
  --@AmtToApplyFgn*-1, @AmtToApplyFgn*-1, 0,  CustPONum,    
  0, 0,  CustPONum, --changed by mah 03/07/13 - corrected incorrect amounts going into TotCost and TotPmt fields    
  DistCode, @CurrencyID, @ExchRate, DiscDueDate,    
  NetDueDate, 0,  SumHistPeriod, 0,    
  0,  0,  0,  0,    
  BillingPeriodFrom,PMTransType, ProjItem, BillingPeriodThru,    
  BillingFormat  ,SourceId ,VoidYn   
 from  tblArTransHeader    
 Where  TransID = @OldTransID     
    
    
  INSERT INTO ALP_tblArTransHeader    
 (    
  ALPTransId,    AlpSiteID, AlpMailSiteYN, AlpJobNum,      
  AlpRep1AmtYn, AlpRep2AmtYn, AlpFromJobYN, AlpSvcYN,      
  AlpRecBillRef, AlpSendToPrintYn,AlpUploadDate, AlpJobNumRmr,      
  AlpSubscriberInvcYn    
 )    
 Select @NewTransID2,    @UnAppldSiteID, AlpMailSiteYN, @AlpJobNum,      
  AlpRep1AmtYn, AlpRep2AmtYn,   
  0, --AlpFromJobYN,   
  AlpSvcYN,      
  AlpRecBillRef, AlpSendToPrintYn,AlpUploadDate, AlpJobNumRmr,      
  AlpSubscriberInvcYn  From ALP_tblArTransHeader  where AlpTransId = @OldTransID   
    
End