  
Create PROCEDURE [dbo].[ALP_qryArAlpCompareReplaceCompletedSiteSysItem]                
@TicketId int,  
@SysItemId int                
As                
SET NOCOUNT ON                
Select * from ALP_tblArAlpReplaceCompletedSiteSysItem         
WHERE     
TicketId <> @TicketId and SysItemid=@SysItemId