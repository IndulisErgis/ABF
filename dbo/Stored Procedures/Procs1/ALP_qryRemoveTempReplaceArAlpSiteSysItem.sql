  
CREATE Procedure [dbo].[ALP_qryRemoveTempReplaceArAlpSiteSysItem]      
@SysItemId int    
    
As      
			
delete from ALP_tblArAlpReplaceSiteSysItem where sysItemId=@SysItemId