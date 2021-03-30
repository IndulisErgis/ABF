CREATE Procedure [dbo].[ALP_qryRevertUpdReplaceArAlpSiteSysItemRemoveYN]      
@SysItemId int ,   
@RemoveYN int  
As      
      
Update ALP_tblArAlpSiteSysItem set RemoveYN =@RemoveYN where sysItemId=@SysItemId