CREATE Procedure [dbo].[ALP_qryUpdateTempReplaceArAlpSiteSysItemQty]          
@SysItemId int,          
@TicketId int,    
@Qty float          
As          
          
Update ALP_tblArAlpReplaceQtySiteSysItem set Qty= @Qty where sysItemId=@SysItemId     
 and TicketId=@TicketId