CREATE Procedure  [dbo].[ALP_qryUpdReplaceArAlpSiteSysItemRemoveYN]      
@SysItemId int,     
@RemoveYN int     
As      
      
Update ALP_tblArAlpSiteSysItem set RemoveYN =@RemoveYN where sysItemId=@SysItemId