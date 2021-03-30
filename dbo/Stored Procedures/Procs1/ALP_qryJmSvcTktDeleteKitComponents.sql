CREATE    Procedure [dbo].[ALP_qryJmSvcTktDeleteKitComponents]        
 @CurrentTicketItemId int, @ID int, @LineNumberPrefix varchar(50) = ''        
--EFI# 1632 MAH 11/09/05 modified for embedded kit deletione        
-- RAVI 12/27/2017 modified for OFF the Set Nocount
AS        
SET NOCOUNT OFF        
        
--delete the components         
DELETE         
FROM ALP_tblJmSvcTktItem        
--WHERE ALP_tblJmSvcTktItem.KitRef = @CurrentTicketItemId AND ALP_tblJmSvcTktItem.TicketId = @ID        
WHERE ALP_tblJmSvcTktItem.TicketId = @ID         
AND       
(      
 (      
  ALP_tblJmSvcTktItem.KitRef = @CurrentTicketItemId        
    OR        
  ALP_tblJmSvcTktItem.LineNumber LIKE (@LineNumberPrefix + '%')      
 )      
 --   OR      
 --  TicketItemId=@CurrentTicketItemId --OR condition added by NSK on 08 Sep 2016.      
)