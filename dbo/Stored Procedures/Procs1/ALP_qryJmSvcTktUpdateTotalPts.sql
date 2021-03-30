
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateTotalPts]	
@TotalPts pDec,
@Ticketid int,
@RevisedBy varchar(20)=null,@ModifiedBy varchar(16)

AS
Update ALP_tbljmsvctkt set TotalPts=@TotalPts,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101)
,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
 where ticketid=@Ticketid