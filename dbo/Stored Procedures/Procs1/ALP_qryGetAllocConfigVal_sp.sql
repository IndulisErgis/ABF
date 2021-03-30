Create PROCEDURE dbo.ALP_qryGetAllocConfigVal_sp                  
@ConfigVal varchar(255) output                  
As                  
SET NOCOUNT ON 
declare @SYSConfigRef int                      
set @SYSConfigRef=0                    
SELECT  @SYSConfigRef=ConfigRef   FROM  SYS. dbo.tblSmConfig  WHERE   (AppId ='AR')  AND (ConfigId = 'GlAcctInv')                      

SELECT ConfigValue  FROM dbo. tblSmConfigValue   WHERE (ConfigRef = @SYSConfigRef) AND (RoleId IS NULL)
RETURN