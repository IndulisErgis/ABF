
CREATE Procedure  [dbo].[ALP_qryUpdSvcTktItemExtSalePrice]     
@TicketItemId int,           
@ExtSalePrice pDec,  
@ModifiedBy varchar(50)  
As            
            
Update ALP_tblJmSvcTktItem set UnitPrice=@ExtSalePrice,ExtSalePrice =@ExtSalePrice,ExtSalePriceFlg=1,  
ModifiedBy=@ModifiedBy,ModifiedDate=getDate()  
where TicketItemId=@TicketItemId