CREATE Procedure [dbo].[ALP_qryDeleteTempReplaceQtySiteSysItem]                
@TicketId int,  
@SysItemId int   
As                
    
delete from ALP_tblArAlpReplaceQtySiteSysItem where TicketId=@TicketId     
and SysItemId=@SysItemId