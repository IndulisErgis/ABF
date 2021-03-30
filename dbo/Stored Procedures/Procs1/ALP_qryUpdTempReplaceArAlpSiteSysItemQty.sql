CREATE Procedure [dbo].[ALP_qryUpdTempReplaceArAlpSiteSysItemQty]        
@SysItemId int,        
@TicketId int,  
@Qty float        
As        
        
Update ALP_tblArAlpReplaceQtySiteSysItem set Qty= (Qty- @Qty) where sysItemId=@SysItemId   
 and TicketId=@TicketId