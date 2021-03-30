CREATE Procedure  [dbo].[ALP_qryTempUpdReplaceArAlpSiteSysItemRemoveYN]          
@SysItemId int,   
@TicketId int,        
@RemoveYN int         
As          
          
Update ALP_tblArAlpReplaceQtySiteSysItem set RemoveYN =@RemoveYN where sysItemId=@SysItemId and TicketId=@TicketId