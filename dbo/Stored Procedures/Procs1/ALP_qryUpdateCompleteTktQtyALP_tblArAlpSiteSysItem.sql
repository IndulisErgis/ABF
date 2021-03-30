Create Procedure [dbo].[ALP_qryUpdateCompleteTktQtyALP_tblArAlpSiteSysItem]              
@SysItemId int,  
@RemoveYN bit,   
@Qty int    
As              
              
update ALP_tblArAlpSiteSysItem  set Qty=Qty-@Qty ,RemoveYN=@RemoveYN  
where sysItemId=@SysItemId