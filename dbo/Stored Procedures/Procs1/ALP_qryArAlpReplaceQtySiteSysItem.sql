  
Create PROCEDURE [dbo].[ALP_qryArAlpReplaceQtySiteSysItem]              
@TicketId int             
As              
SET NOCOUNT ON              
SELECT *       
FROM ALP_tblArAlpReplaceQtySiteSysItem              
WHERE   
ALP_tblArAlpReplaceQtySiteSysItem.TicketId = @TicketId