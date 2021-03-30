  
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktItemsCheckOnlyParts]    
@ID int,
@ItemId varchar(24)
  
As    
SET NOCOUNT ON    
SELECT Itemid from ALP_tblJmSvcTktItem   
where ALP_tblJmSvcTktItem.TicketItemId = @ID   
and dbo.ufn_IsItemIsPart(@ItemId)=1