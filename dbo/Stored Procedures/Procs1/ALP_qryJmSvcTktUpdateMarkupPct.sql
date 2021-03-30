
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateMarkupPct]	
@PworkLabMarkupPct float,
@Ticketid int,
@RevisedBy varchar(50)=null,@ModifiedBy varchar(50)
--MAH 05/02/2017 - increased size of the ModifiedBy parameter (from 16 to 50) and REvisedBy (from 20 to 50) 

AS
Update ALP_tbljmsvctkt set PworkLabMarkupPct=@PworkLabMarkupPct
,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101)
,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
 where ticketid=@Ticketid