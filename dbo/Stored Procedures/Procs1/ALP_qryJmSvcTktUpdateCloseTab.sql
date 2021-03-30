
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateCloseTab] 
@CompleteDate varchar(24),
@ResolID int,
@ResolComments text,
@CloseDate datetime,
@CancelDate datetime,
@ToSchDate datetime,
@TurnoverDate datetime,
@StartRecurDate datetime,
@NextRecurDate datetime,
@CommPaidDate datetime,
@RevisedDate datetime,
--Below @RevisedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@RevisedBy varchar(50),
@TicketId int,
@ReturnYn bit,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50),
--Modified date added by NSK on 8th Apr 2014(GetDate() was used to fetch the date earlier)
@ModifiedDate datetime


AS
update ALP_tbljmsvctkt set CompleteDate=@CompleteDate,ResolID=@ResolID,ResolComments=@ResolComments,CloseDate=@CloseDate,CancelDate=@CancelDate,
ToSchDate=@ToSchDate,TurnoverDate=@TurnoverDate,StartRecurDate=@StartRecurDate,ReturnYn=@ReturnYN,
NextRecurDate=@NextRecurDate,CommPaidDate=@CommPaidDate,RevisedDate=@RevisedDate,RevisedBy=@RevisedBy
,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate
where ticketid=@TicketId