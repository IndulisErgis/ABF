
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateProjData]	
@OrderDate datetime,
@Contact varchar(25),
@ContactPhone varchar(15),
@BranchId int,
@CustPoNum varchar(25),
@Ticketid int,
@RevisedBy varchar(50)=null,
@ModifiedBy varchar(50)
--MAH 05/02/2017 - increased size of the ModifiedBy parameter (from 16 to 50 ) and RevisedBy (from 20 to 50)

AS
Update ALP_tbljmsvctkt set OrderDate=@OrderDate,Contact=@Contact,ContactPhone=@ContactPhone,BranchId=@BranchId,CustPoNum=@CustPoNum,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101)
,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
 where ticketid=@Ticketid