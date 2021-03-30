    
    
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateGeneralTab]     
@Sysid int,    
@RepPlanId int,    
@PriceId varchar(10),    
@LseYN bit,    
@WorkCodeId int,    
@WorkDesc text,    
@OtherComments text,    
@BranchId int,    
@DivId int,    
@SkillId int,    
@DeptId int,    
@CustId varchar(10),    
@ContractId int,    
@Contact varchar(25),    
@ContactPhone varchar(15),    
@LeadTechId int,    
@EstHrs float,    
@PrefDate datetime,    
@PrefTime varchar(50),    
@ProjectId varchar(10),    
@CustPoNum varchar(25),    
@ReschDate datetime,    
@TicketId int,    
--Below @RevisedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017    
@RevisedBy varchar(50)=null,    
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017    
@ModifiedBy varchar(50),    
--Revised date and Modified date added by NSK on 8th Apr 2014(GetDate() was used to fetch the date earlier)    
@RevisedDate datetime,    
@ModifiedDate datetime    
,@HoldInvCommitted bit -- Added by NSK on 26 Oct 2018 for bug id 819    
AS    
update ALP_tbljmsvctkt set sysid=@Sysid ,repplanid=@RepPlanId, priceid=@PriceId ,lseYN=@LseYN,workcodeid=@WorkCodeId,workdesc=@WorkDesc,    
othercomments=@OtherComments ,branchid=@BranchId,divid=@DivId,skillid=@SkillId,deptid=@DeptId,custid=@CustId,contractid=@ContractId,contact=@Contact,    
contactphone=@ContactPhone,leadtechid=@LeadTechId,esthrs=@EstHrs,prefdate=@PrefDate,preftime=@PrefTime,projectid=@ProjectId  ,CustPoNum=@CustPoNum,    
ReschDate=@ReschDate,RevisedBy=@RevisedBy,RevisedDate=@RevisedDate ,     
ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate   
,HoldInvCommitted= @HoldInvCommitted -- Added by NSK on 26 Oct 2018 for bug id 868  
where ticketid=@TicketId