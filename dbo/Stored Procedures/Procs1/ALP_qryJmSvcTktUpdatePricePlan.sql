CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdatePricePlan]  
 @PriceId varchar(10),  
 @Ticketid int   
AS  
update ALP_tbljmsvctkt set   
 PriceId=@PriceId   
where ticketid=@Ticketid