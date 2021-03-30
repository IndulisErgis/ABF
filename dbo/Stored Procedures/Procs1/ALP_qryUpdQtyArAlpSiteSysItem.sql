CREATE Procedure [dbo].[ALP_qryUpdQtyArAlpSiteSysItem]            
@SysItemId int,    
@Qty int      
As            
Update ALP_tblArAlpSiteSysItem set Qty=Qty + @Qty  
where sysItemId=@SysItemId