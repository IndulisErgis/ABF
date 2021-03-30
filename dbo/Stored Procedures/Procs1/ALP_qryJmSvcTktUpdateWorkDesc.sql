
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateWorkDesc]	
@WorkDesc text,
@Ticketid int,
@RevisedBy varchar(20)=null,
@ModifiedBy varchar(16)
AS
UPDATE dbo.ALP_tblJmSvcTkt SET WorkDesc =@WorkDesc,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101) 
,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
where TicketId=@Ticketid