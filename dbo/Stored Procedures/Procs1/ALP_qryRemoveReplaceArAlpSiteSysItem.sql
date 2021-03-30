CREATE Procedure [dbo].[ALP_qryRemoveReplaceArAlpSiteSysItem]    
@SysItemId int  
  
As    
    
delete from ALP_tblArAlpSiteSysItem where sysItemId=@SysItemId