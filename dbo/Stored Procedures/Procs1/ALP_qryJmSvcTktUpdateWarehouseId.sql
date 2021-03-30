
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateWarehouseId]	
@TicketItemId int,
@WhseID varchar(10),
@ModifiedBy varchar(16),
@ModifiedDate datetime


AS
Update ALP_tbljmsvctktitem set WhseID=@WhseID 
,ModifiedBy=@ModifiedBy,ModifiedDate=@ModifiedDate
where TicketItemId=@TicketItemId