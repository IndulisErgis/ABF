CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateProjectId]	
@TicketId int,
@ProjectId varchar(10),
@ModifiedBy varchar(50),
@ModifiedDate datetime
--MAH 05/02/2017 - increased size of the ModifiedBy parameter, from 16 to 50 


AS
Update ALP_tbljmsvctkt set ProjectId=@ProjectId
,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate,
RevisedBy=@ModifiedBy,RevisedDate=@ModifiedDate
where TicketId=@TicketId