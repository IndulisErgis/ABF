
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateStatus]	
@Status varchar(10),
@Ticketid int,
@RevisedBy varchar(20)=null,@ModifiedBy varchar(16)

AS
Update ALP_tbljmsvctkt set status=@Status,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101)
,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
 where ticketid=@Ticketid