  
Create PROCEDURE [dbo].[ALP_qryArAlpUndoReplaceCompletedSiteSysItem]                
@TicketId int             
As                
SET NOCOUNT ON                
Select * from ALP_tblArAlpReplaceCompletedSiteSysItem         
WHERE     
TicketId = @TicketId