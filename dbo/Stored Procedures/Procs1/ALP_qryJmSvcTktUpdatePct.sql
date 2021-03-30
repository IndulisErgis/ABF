--modified by Shanthakumar 2/26/14 - changed precision of pct fields
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdatePct]	
@PriceMethod int,
@MarkupPct numeric(20,10),
@PartsOhPct numeric(20,10),
@Ticketid int,
@RevisedBy varchar(50)=null,@ModifiedBy varchar(50)
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 , and RevisedBy from 20 to 50

AS
Update ALP_tbljmsvctkt set PriceMethod=@PriceMethod,MarkupPct=@MarkupPct,PartsOhPct=@PartsOhPct,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101)
,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()
 where ticketid=@Ticketid