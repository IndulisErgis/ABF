
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateTrackingTurnover]	
@Ticketid int,
@ToSchDate datetime=null,
@TurnoverDate datetime=null,
@RevisedBy varchar(20)=null
AS
Update ALP_tbljmsvctkt set ToSchDate=@ToSchDate,TurnoverDate=@TurnoverDate,RevisedBy=@RevisedBy,RevisedDate=CONVERT(VARCHAR(10),GETDATE(),101) where ticketid=@Ticketid