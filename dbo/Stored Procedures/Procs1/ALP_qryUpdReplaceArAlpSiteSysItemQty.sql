CREATE Procedure [dbo].[ALP_qryUpdReplaceArAlpSiteSysItemQty]    
@SysItemId int,    
@Qty float    
As    
    
Update ALP_tblArAlpSiteSysItem set Qty= (Qty- @Qty) where sysItemId=@SysItemId