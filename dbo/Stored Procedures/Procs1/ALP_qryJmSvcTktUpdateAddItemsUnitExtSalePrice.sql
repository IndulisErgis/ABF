Create PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateAddItemsUnitExtSalePrice]              
@UnitPrice pDec,
@TicketItemId int,   
@ModifiedBy varchar(50)           
AS              
update ALP_tblJmSvcTktItem set UnitPrice=@UnitPrice
,ExtSalePrice=@UnitPrice,ModifiedBy=@ModifiedBy,ModifiedDate=GETDATE()   
where ticketitemid=@TicketItemId