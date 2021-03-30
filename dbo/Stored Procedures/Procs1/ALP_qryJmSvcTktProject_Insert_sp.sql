
    
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktProject_Insert_sp]     
@SvcTktProjectId int OUTPUT,    
@ProjectId varchar(10)= null,    
@SiteId int,    
@Descr varchar(50)= null,    
@PromoId int=null,    
@LeadSourceId int=null,    
@ReferBy varchar(50)= null,    
@FudgeFactor pDec=null,    
@AdjPoints float = null,    
@AdjComments text = null,    
@EstMatCost float = null,    
@EstLabCost float = null,    
@EstLabHrs int=null,    
@NewWorkYn bit=null,    
@MarketCodeId int=null,    
@FudgeFactorHrs pDec=null,    
@AdjHrs pDec=null,    
@InitialOrderDate DateTime=null,    
@Contact varchar(25)= null,    
@ContactPhone varchar(15)= null,    
@BranchID int=null,    
@CustPoNum varchar(25)= null,  
--Added by NSK on 25 May 2015  
@LeadSalesRepID varchar(3) =null,
--Added by NSK on 29 Dec 2015 for bug id 398
--start
@BillingNotes ntext=null,
@ProjectNotes ntext=null
--end  
AS    
insert into ALP_tblJmSvcTktProject(ProjectId,SiteId,[Desc],PromoId,LeadSourceId,ReferBy,FudgeFactor,    
AdjPoints,AdjComments,EstMatCost,EstLabCost,EstLabHrs,NewWorkYn,MarketCodeId,FudgeFactorHrs,AdjHrs,    
InitialOrderDate,Contact,ContactPhone,BranchID,CustPoNum,LeadSalesRepID,
BillingNotes,ProjectNotes) -- Billing notes and project notes added by NSK on 29 Dec 2015 for bug id 398  
Values( @ProjectId,@SiteId,@Descr,@PromoId,@LeadSourceId,@ReferBy,@FudgeFactor,    
@AdjPoints,@AdjComments,@EstMatCost,@EstLabCost,@EstLabHrs,@NewWorkYn,@MarketCodeId,@FudgeFactorHrs,@AdjHrs,    
@InitialOrderDate,@Contact,@ContactPhone,@BranchID,@CustPoNum,@LeadSalesRepID,
@BillingNotes,@ProjectNotes)  -- Billing notes and project notes added by NSK on 29 Dec 2015 for bug id 398  
    
set @SvcTktProjectId =@@Identity