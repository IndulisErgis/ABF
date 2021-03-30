  
Create PROCEDURE [dbo].[ALP_qryArAlpReplaceSiteSysItem]              
@TicketId int             
As              
SET NOCOUNT ON              
SELECT *       
FROM ALP_tblArAlpReplaceSiteSysItem              
WHERE   
ALP_tblArAlpReplaceSiteSysItem.TicketId = @TicketId