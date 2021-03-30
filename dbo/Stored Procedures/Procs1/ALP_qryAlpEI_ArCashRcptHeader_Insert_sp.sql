  
   CREATE    procedure [dbo].[ALP_qryAlpEI_ArCashRcptHeader_Insert_sp]    
 @RcptDetailID  int,    
 @AmtToApply   decimal(20,10),  
 @InvcNum  varchar(15),  
 @CurrencyID  pCurrency, --By Sudharson 09/29/2010 - Added @CurrencyID parameter  
 @ExchRate  pDec,  --By Sudharson 09/29/2010 - Added @ExchRate parameter  
 @InvcTransID  varchar(15),  
 @SiteID int,  
 @RcptHeaderID int OUTPUT  
As    
 /*  
  Created by NP for EFI#1869 on 05/06/10  
 */  
 --mah 1/23/14: added Source ID column to insert.  Required field
Begin    
 select top 1 @RcptHeaderID = RcptHeaderID from tblArCashRcptDetail  where RcptDetailID = @RcptDetailID  
 Insert into   
  tblArCashRcptHeader  
   (   
     DepositID, BankID,  PmtDate, PmtAmt,  AgingPd,  
     CheckNum, CustId,  GLAcct,  GLPeriod, FiscalYear,  
     PmtMethodId, CcHolder, CcNum,  CcExpire, CcAuth,  
     Note,  CurrencyID, ExchRate, InvcTransID, InvcAppID,  
     SumHistPeriod, SourceId  
   )  
 Select   
     DepositID, BankID,  PmtDate, @AmtToApply, AgingPd,  
     CheckNum, CustId,  GLAcct,  GLPeriod, FiscalYear,  
     PmtMethodId, CcHolder, CcNum,  CcExpire, CcAuth,  
     Note,  @CurrencyID, @ExchRate, @InvcTransID, InvcAppID,  
     SumHistPeriod , SourceId 
 from    
  tblArCashRcptHeader  
 Where    
  RcptHeaderID = @RcptHeaderID  
   
 select @RcptHeaderID = scope_identity()  
 -- Inserting AmtToAppy * -1 row  
 Insert into   
  tblArCashRcptHeader  
   (   
     DepositID, BankID,  PmtDate, PmtAmt,  AgingPd,  
     CheckNum, CustId,  GLAcct,  GLPeriod, FiscalYear,  
     PmtMethodId, CcHolder, CcNum,  CcExpire, CcAuth,  
     Note,  CurrencyID, ExchRate, InvcTransID, InvcAppID,  
     SumHistPeriod , SourceId 
   )  
 Select   
     DepositID, BankID,  PmtDate, @AmtToApply*-1, AgingPd,  
     CheckNum, CustId,  GLAcct,  GLPeriod, FiscalYear,  
     PmtMethodId, CcHolder, CcNum,  CcExpire, CcAuth,  
     Note,  @CurrencyID, @ExchRate, InvcTransID, InvcAppID,  
     SumHistPeriod  , SourceId
 from    
  tblArCashRcptHeader  
 Where    
  RcptHeaderID = @RcptHeaderID  
end