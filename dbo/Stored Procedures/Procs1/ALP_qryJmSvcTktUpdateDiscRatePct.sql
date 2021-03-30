CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateDiscRatePct]	
@DiscRatePct float,
@TicketId int,
--Added by NSK on 08 May 2014 to pass the revised date
@RevisedDate datetime,
--Below @RevisedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@RevisedBy varchar(50)=null,
--Below @ModifiedBy  parameter length changed from 16 to 50 char, modified by ravi on 02 May 2017
@ModifiedBy varchar(50)


AS
Update ALP_tbljmsvctkt set DiscRatePct=@DiscRatePct 
,RevisedBy=@RevisedBy,RevisedDate=@RevisedDate
,ModifiedBy=@ModifiedBy,ModifiedDate=@RevisedDate
where ticketid=@TicketId