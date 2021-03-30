Create PROCEDURE [dbo].[ALP_qryDelArAlpSiteSysItem]                  
@SysItemId int               
As                  
SET NOCOUNT ON                  
delete FROM ALP_tblArAlpSiteSysItem     
where SysItemId=@SysItemId