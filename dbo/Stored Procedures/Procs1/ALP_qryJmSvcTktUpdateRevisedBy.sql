CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateRevisedBy]   
@Ticketid int,  
@RevisedBy varchar(50)=null  
--NSK 07/17/2017 - Created for bug id 602. When the Alp_tblJmSvcTktItem table is modified it should update the revised by in Alp_tblJmSvcTkt table  
  
AS  
Update ALP_tbljmsvctkt set   
RevisedBy=@RevisedBy,RevisedDate=GETDATE()  
,ModifiedBy=@RevisedBy,ModifiedDate=GETDATE()  
 where ticketid=@Ticketid