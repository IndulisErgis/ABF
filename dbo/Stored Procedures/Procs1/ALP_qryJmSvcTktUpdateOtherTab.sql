CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateOtherTab]     
@SalesRepId varchar(3),    
@CommAmt pDec,    
@CommPayNowYn bit,    
@BaseInstPrice pDec,    
@CsConnectYn bit,    
@RMRAdded pDec,    
@RMRExpense pDec,    
@DiscRatePct float,    
@ContractMths int,    
@EstCostParts pDec,    
@EstCostLabor pDec,    
@EstCostMisc pDec,    
@EstHrs_FromQM decimal(18,2),  -- Modified by NSK on 30 Jan 2015 decimal datatype changed to decimal with precision  
@Ticketid int,   
@TotalPts pDec, -- Added by NSK on 20 mar 2014    
@RevisedBy varchar(50)=null,    
@ModifiedBy varchar(50),    
--Revised date and Modified date added by NSK on 8th Apr 2014(GetDate() was used to fetch the date earlier)    
@RevisedDate datetime,    
@ModifiedDate datetime    
 --MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 , and RevisedBy from 20 to 50   
,@OriginalEstimatesflg bit --Added by ravi on 6th nov 2019 for bug id 979
AS    
update ALP_tbljmsvctkt set SalesRepId=@SalesRepId,CommAmt=@CommAmt,CommPayNowYn=@CommPayNowYn,BaseInstPrice=@BaseInstPrice,    
CsConnectYn=@CsConnectYn,RMRAdded=@RMRAdded,RMRExpense=@RMRExpense,DiscRatePct=@DiscRatePct,ContractMths=@ContractMths,    
EstCostParts=@EstCostParts,EstCostLabor=@EstCostLabor,EstCostMisc=@EstCostMisc,EstHrs_FromQM=@EstHrs_FromQM,RevisedBy=@RevisedBy,RevisedDate=@RevisedDate    
,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate    
,TotalPts=@TotalPts ---- TotalPts Added by NSK on 20 mar 2014    
,OriginalEstimatesflg = @OriginalEstimatesflg --Added by ravi on 6th nov 2019 for bug id 979
where ticketid=@Ticketid