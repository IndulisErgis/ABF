
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTkt_Insert_sp]             
  @NewTicketId int OUTPUT,            
  @SiteId int,            
  @CreditOverrideDate  datetime= null,            
  @CreditOverrideBy varchar(20)= null,            
  @Contact varchar(25)= null,            
  @ContactPhone varchar(15)= null,            
  @WorkDesc text= null, -- varchar(255) changed to text on 14 Jun 2016           
  @WorkCodeId int= null,            
  @SysId int= null,            
  @CustId varchar(10) = null,             
  @CustPoNum varchar(25) = null,             
  @RepPlanId int = null,            
  @PriceId varchar(15) = null,            
  @BranchId int = null,            
  @DivId int = null,            
  @DeptId int = null,            
  @SkillId int = null,            
  @LeadTechId int= null,            
  @EstHrs float = null,            
  @PrefDate datetime  = null,            
  @PrefTime varchar(50)  = null,            
  @OtherComments text  = null, -- varchar(255) changed to text on 14 Jun 2016           
  @ShowDetailYn bit = null,            
  @CloseDate datetime = null,            
  @BilledYN bit = null,            
  @OutOfRegYN bit = null,            
  @HolidayYN bit = null,            
  @SalesRepId varchar(3) = null,            
  @RevisedBy varchar(20) = null,             
  @RevisedDate datetime = null,            
  @ProjectId varchar(10) = null,            
  @ContractId int = null,            
  @CsConnectYn bit = null,            
  @LseYn bit = null,            
  @CompleteDate datetime = null,            
  @TurnoverDate datetime = null,            
  @StartRecurDate datetime = null,            
  @NextRecurDate datetime = null,            
  @CommPaidDate datetime = null,            
  @RmrExpense pDec = null,            
  @DiscRatePct float  = null,            
  @ContractMths int = null,            
  @CancelDate datetime = null,            
  @BoDate datetime = null,            
  @StagedDate datetime = null,            
  @BinNumber varchar(10) = null,            
  @ToSchDate datetime = null,            
  --Below @CreatedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017          
  @CreateBy varchar(50) = null,            
  @SalesTax pDec = null,            
  @CommAmt pDec = null,            
  @RMRAdded pDec = null,            
  @PworkLabMarkupPct float = null,            
  @BaseInstPrice pDec = null,            
  @OrderDate datetime = null,            
  @ReschDate datetime = null,            
  @PriceMethod int = null,            
  @PartsPrice pDec = null,            
  @PartsOhPct numeric(20,10) = null,            
  @MarkupPct numeric(20,10) = null,            
  @MarkupAmt pDec = null,            
  @MinHrs float = null,            
  @MinPrice pDec = null,            
  @RegHrs float = null,            
  @OutOfRegHrs float = null,            
  @HolHrs float = null,            
  @HrlyReg pDec = null,            
  @HrlyOutOfReg pDec = null,            
  @HrlyHol pDec = null,            
  @LabPriceTotal pDec = null,            
  @TotalPts pDec = null,            
  @BatchId varchar(6) = null,            
  @BillingFormat int = null,            
  @InvcDate datetime = null,            
  @InvcNum varchar(15) = null,            
  @CommentAddlDesc text = null,  -- varchar(255) changed to text on 14 Jun 2016          
  @PartsItemId varchar(24) = null,            
  @PartsDesc varchar(35) = null,            
  @PartsAddlDesc text = null, -- varchar(255) changed to text on 14 Jun 2016           
  @PartsTaxClass int = null,            
  @LaborItemId varchar(24) = null,            
  @LaborDesc varchar(35) = null,            
  @LaborAddlDesc text = null,  -- varchar(255) changed to text on 14 Jun 2016          
  @LaborTaxClass int = null,            
  @TaxAmtTotal float = null,            
  @MailSiteYn bit = null,            
  @SendToPrintYn bit = null,            
  @EstCostParts pDec = null,            
  @EstCostLabor pDec = null,            
  @EstCostMisc pDec = null,            
  @EstHrs_FromQM decimal = null,            
  @CommSplitYn bit = null,            
  @CommPayNowYn bit = null,            
  @ResolId int = null,            
  @ResolComments text = null,  -- varchar(255) changed to text on 14 Jun 2016          
 @CauseId int = null,            
  @CauseComments text = null, -- varchar(255) changed to text on 14 Jun 2016           
  @ReturnYN bit = null,          
  --Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017            
  @ModifiedBy varchar(50)            
       
  ,@OriginalEstimatesflg bit -- Added by ravi on 6th nov 2019 for bug id 979    
  ,@HoldInvCommitted bit  -- Added by NSK on 03 Jan 2019 for bug id 868  
AS            
insert into ALP_tblJmSvcTkt            
  (CreateDate,SiteId,Status,CreditOverrideDate,CreditOverrideBy,            
  Contact,ContactPhone,WorkDesc,WorkCodeId,SysId,CustId,CustPoNum,RepPlanId,PriceId,            
  BranchId,DivId,DeptId,SkillId,LeadTechId,EstHrs,PrefDate,PrefTime,OtherComments,            
  ShowDetailYn,CloseDate,BilledYN,OutOfRegYN,HolidayYN,SalesRepId,RevisedBy,RevisedDate,            
  ProjectId,ContractId,CsConnectYn,LseYn,CompleteDate,TurnoverDate,StartRecurDate,            
  NextRecurDate,CommPaidDate,RmrExpense,DiscRatePct,ContractMths,CancelDate,BoDate,            
  StagedDate,BinNumber,ToSchDate,CreateBy,SalesTax,CommAmt,RMRAdded,PworkLabMarkupPct,            
  BaseInstPrice,OrderDate,ReschDate,PriceMethod,PartsPrice,PartsOhPct,MarkupPct,MarkupAmt,            
  MinHrs,MinPrice,RegHrs,OutOfRegHrs,HolHrs,HrlyReg,HrlyOutOfReg,            
  HrlyHol,LabPriceTotal,TotalPts,BatchId,BillingFormat,InvcDate,InvcNum,CommentAddlDesc,            
  PartsItemId,PartsDesc,PartsAddlDesc,PartsTaxClass,LaborItemId,LaborDesc,LaborAddlDesc,            
  LaborTaxClass,TaxAmtTotal,MailSiteYn,SendToPrintYn,EstCostParts,EstCostLabor,            
  EstCostMisc,EstHrs_FromQM,CommSplitYn,CommPayNowYn,ResolId,ResolComments,CauseId,            
  CauseComments,ReturnYN --  Removed ModifiedBy,ModifiedDate from the insert columns to update null by NSK on 18 Mar 2014             
        
  ,OriginalEstimatesflg--Added by ravi on 6th nov 2019 for bug id 979       
  ,HoldInvCommitted)--HoldInvCommitted added by NSK on 03 Jan 2019 for bug id 868  
Values            
  ( CONVERT(VARCHAR(10),GETDATE(),101),@SiteId,'NEW',@CreditOverrideDate,@CreditOverrideBy,            
  @Contact,@ContactPhone,@WorkDesc,@WorkCodeId,@SysId,@CustId,@CustPoNum,@RepPlanId,@PriceId,            
  @BranchId,@DivId,@DeptId,@SkillId,@LeadTechId,@EstHrs,@PrefDate,@PrefTime,@OtherComments,            
  @ShowDetailYn,@CloseDate,@BilledYN,@OutOfRegYN,@HolidayYN,@SalesRepId,@RevisedBy,@RevisedDate,            
  @ProjectId,@ContractId,@CsConnectYn,@LseYn,@CompleteDate,@TurnoverDate,@StartRecurDate,            
  @NextRecurDate,@CommPaidDate,@RmrExpense,@DiscRatePct,@ContractMths,@CancelDate,@BoDate,            
  @StagedDate,@BinNumber,@ToSchDate,@CreateBy,@SalesTax,@CommAmt,@RMRAdded,@PworkLabMarkupPct,            
  @BaseInstPrice,@OrderDate,@ReschDate,@PriceMethod,@PartsPrice,@PartsOhPct,@MarkupPct,@MarkupAmt,            
  @MinHrs,@MinPrice,@RegHrs,@OutOfRegHrs,@HolHrs,@HrlyReg,@HrlyOutOfReg,            
  @HrlyHol,@LabPriceTotal,@TotalPts,@BatchId,@BillingFormat,@InvcDate,@InvcNum,@CommentAddlDesc,            
  @PartsItemId,@PartsDesc,@PartsAddlDesc,@PartsTaxClass,@LaborItemId,@LaborDesc,@LaborAddlDesc,            
  @LaborTaxClass,@TaxAmtTotal,@MailSiteYn,@SendToPrintYn,@EstCostParts,@EstCostLabor,            
  @EstCostMisc,@EstHrs_FromQM,@CommSplitYn,@CommPayNowYn,@ResolId,@ResolComments,@CauseId,            
  @CauseComments,@ReturnYN--  Removed @ModifiedBy,GETDATE() from the values to update null by NSK on 18 Mar 2014             
         
  ,@OriginalEstimatesflg--Added by ravi on 6th nov 2019 for bug id 979   
  ,@HoldInvCommitted)--HoldInvCommitted added by NSK on 03 Jan 2019 for bug id 868  
    
            
set @NewTicketId =@@Identity