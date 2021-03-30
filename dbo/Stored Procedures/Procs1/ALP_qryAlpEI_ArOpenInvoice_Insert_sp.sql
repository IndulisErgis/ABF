-- select * from TblAROpeninvoice  
CREATE    procedure [dbo].[ALP_qryAlpEI_ArOpenInvoice_Insert_sp]  
/*  
 Created By Np for EFI#1869 on 05/01/2010  
*/  
 @CustId  Varchar(10),  
 @InvcNum  varchar(15),  
 @UnAppldInvcNum varchar(15),  
 @RecType  smallint,  
 @Status  tinyint,  
 @DistCode Varchar(6),  
 @TermsCode Varchar(6),  
 @CreditTransDate datetime='1/1/1753',--EFI# 1869 SUDHARSON 12/03/2010 - Modified @TransDate as @CreditTransDate as per TestResults_120110.docx  
 @InvcTransDate datetime='1/1/1753',--EFI# 1869 SUDHARSON 12/03/2010 - Added as per TestResults_120110.docx  
 @DiscDueDate datetime='1/1/1753',  
 @NetDueDate datetime='1/1/1753',  
 @Amt  decimal(20,10),  
 @AmtFgn  decimal(20,10),  
 @DiscAmt decimal(20,10)=0,  
 @DiscAmtFgn decimal(20,10)=0,  
 @PmtMethodId varchar(10)= null,  
 @CheckNum varchar(10)= null,  
 @JobId  varchar(10)=null,  
 @CurrencyId varchar(6),  
 @ExchRate decimal(20,10)=null,  
 @GlPeriod smallint,  
 @FiscalYear smallint,  
 @PhaseId varchar(10),  
 @ProjId  varchar(10),  
 @InvcSiteId int,  
 @CreditSiteID int,  
 @AlpTransId varchar(8)  
-- Not included in TravAr  
-- @AlpMailSiteYn bit,  
-- @AlpPostRun varchar(14),  
-- @AlpTransId varchar(8),  
-- @AlpSubscriberInvcYn bit  
As  
Begin  

 Declare @alpCounter int;
 INSERT INTO    
  TblAROpeninvoice    
    (   
     CustId,  InvcNum,  RecType,  Status,  DistCode,   
     TermsCode,  TransDate,  DiscDueDate,  NetDueDate, Amt,    
     AmtFgn,  DiscAmt,  DiscAmtFgn,  PmtMethodId,  CheckNum,   
     JobId,   CurrencyId,  ExchRate,  GlPeriod,  FiscalYear,   
     PhaseId,  ProjId   
    )  
  VALUES   
    (   
     @CustId, @InvcNum, @RecType, @Status, @DistCode,  
     @TermsCode,   
     case   
      when @CreditTransDate>@InvcTransDate Then @CreditTransDate   
      else @InvcTransDate   
     end,@DiscDueDate, @NetDueDate, @Amt,  
     @AmtFgn, @DiscAmt, @DiscAmtFgn, @PmtMethodId, @CheckNum,  
     @JobId,  @CurrencyId, @ExchRate, @GlPeriod, @FiscalYear,  
     @PhaseId, @ProjId 
    )  
    

	 set @alpCounter=SCOPE_IDENTITY();
 
    INSERT INTO  ALP_tblAROpeninvoice (   AlpCounter, AlpCustId, AlpInvcNum, AlpSiteId, AlpTransId       )  
	VALUES       (  @alpCounter       ,@CustId, @InvcNum,   @InvcSiteId, @AlpTransId      )  
    
    
    
     
 INSERT INTO    
  TblAROpeninvoice    
    (   
     CustId,  InvcNum,  RecType,  Status,  DistCode,   
     TermsCode,  TransDate,  DiscDueDate, NetDueDate,  Amt,    
     AmtFgn,  DiscAmt,  DiscAmtFgn,  PmtMethodId,  CheckNum,   
     JobId,   CurrencyId,  ExchRate, GlPeriod,  FiscalYear,   
     PhaseId,  ProjId  
    )  
  VALUES   
          (   
     @CustId, @UnAppldInvcNum,@RecType, @Status, @DistCode,  
     @TermsCode, @CreditTransDate, @DiscDueDate, @NetDueDate, @Amt*-1,  
     @AmtFgn*-1, @DiscAmt*-1, @DiscAmtFgn*-1, @PmtMethodId, @CheckNum,  
     @JobId,  @CurrencyId, @ExchRate, @GlPeriod, @FiscalYear,  
     @PhaseId, @ProjId  
    )  
    
    Set @alpCounter =SCOPE_IDENTITY ();
    INSERT INTO    Alp_tblAROpeninvoice ( AlpCounter, AlpCustId, AlpInvcNum, AlpSiteId, AlpTransId    )  
    VALUES   (    @alpCounter , @CustId, @UnAppldInvcNum,@CreditSiteID, @AlpTransId )  
    
End