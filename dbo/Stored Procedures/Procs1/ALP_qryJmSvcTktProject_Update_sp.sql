      
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktProject_Update_sp]       
@SvcTktProjectId int,      
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
@CustPoNum varchar(25)= null ,    
--LeadSalesRepId added by NSK on 25 May 2015    
@LeadSalesRepID varchar(3)=null,    
--Added by NSK on 29 Dec 2015 for bug id 398  
--start  
@BillingNotes ntext=null,  
@ProjectNotes ntext=null  
--end   
--Added by NSK on 19 Dec 2018 for bug id 868
--start
,@HoldProjInvCommitted bit
--end 
AS      
update ALP_tblJmSvcTktProject set [Desc]=@Descr,PromoId=@PromoId,LeadSourceId=@LeadSourceId,ReferBy=@ReferBy,FudgeFactor=@FudgeFactor,      
AdjPoints=@AdjPoints,AdjComments=@AdjComments,EstMatCost=@EstMatCost,EstLabCost=@EstLabCost,EstLabHrs=@EstLabHrs,NewWorkYn=@NewWorkYn,      
MarketCodeId=@MarketCodeId,FudgeFactorHrs=@FudgeFactorHrs,AdjHrs=@AdjHrs,InitialOrderDate=@InitialOrderDate,Contact=@Contact,ContactPhone=@ContactPhone,      
BranchID=@BranchID,CustPoNum=@CustPoNum,      
--Below line added by NSK on 25 May 2015    
LeadSalesRepId=@LeadSalesRepID,  
--Below line added by NSK on 29 Dec 2015  
BillingNotes=@BillingNotes,ProjectNotes=@ProjectNotes  
--Below line added by NSK on 19 Dec 2018 for bug id 868
,HoldProjInvCommitted=@HoldProjInvCommitted
where SvcTktProjectId =@SvcTktProjectId