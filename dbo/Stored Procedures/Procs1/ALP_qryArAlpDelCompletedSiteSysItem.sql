  
Create PROCEDURE [dbo].[ALP_qryArAlpDelCompletedSiteSysItem]                
@TicketId int             
As                
SET NOCOUNT ON                
delete FROM ALP_tblArAlpReplaceCompletedSiteSysItem   
where TicketId=@TicketId