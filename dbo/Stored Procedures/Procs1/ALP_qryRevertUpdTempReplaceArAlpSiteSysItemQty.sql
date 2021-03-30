CREATE Procedure [dbo].[ALP_qryRevertUpdTempReplaceArAlpSiteSysItemQty]          
@SysItemId int,    
@TicketId int,        
@Qty float          
As          
          
Update ALP_tblArAlpReplaceQtySiteSysItem set Qty= (Qty+@Qty) where sysItemId=@SysItemId   
 and TicketId=@TicketId