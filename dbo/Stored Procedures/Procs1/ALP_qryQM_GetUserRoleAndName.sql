  
CREATE  PROCEDURE dbo.ALP_qryQM_GetUserRoleAndName    
AS    
DECLARE @UID integer    
--DECLARE @UName varchar(30)    
DECLARE @start as integer    
DECLARE @length as integer  
DECLARE @Role varchar(20)  
DECLARE @UName varchar(30)       
SET @UID = null    
SET @Role = ''    
SET @UName = SYSTEM_USER
If exists (SELECT SU.uid    
  FROM sysusers SU    
  where SU.name = @UName)    
 BEGIN    
  SET @UID = (SELECT SU.uid    
   FROM sysusers SU    
   where SU.name = @UName)    
 END    
 ELSE BEGIN    
  SET @start = 1    
  SET @length = LEN(@UName)    
  SET @start = @start + PATINDEX('%\%',@UName)    
  SET @length = @length - @start + 1    
  SET @UName = SUBSTRING(SYSTEM_USER, @start,@length)     
  IF exists (SELECT SU.uid    
   FROM sysusers SU    
   where SU.Name = @UName)    
  BEGIN    
   SET @UID = (SELECT SU.uid    
    FROM sysusers SU    
    where SU.name = @UName)    
  END    
    
 END    
If Exists (    
 SELECT  u.[name]     
 FROM sysmembers m INNER JOIN sysusers u ON  m.groupuid = u.uid    
 WHERE m.memberuid = @UID and u.[name] = 'QM_Admin')    
BEGIN    
 SET @Role='QM_Admin'    
END    
ELSE BEGIN    
 If Exists (    
  SELECT  u.[name]     
  FROM sysmembers m INNER JOIN sysusers u ON  m.groupuid = u.uid    
  WHERE m.memberuid = @UID and u.[name] = 'QM_Mgr')    
 BEGIN    
  SET @Role = 'QM_Mgr'    
 END    
 ELSE BEGIN    
  SET @Role = 'QM_User'    
 END    
    
END   
SELECT @Role, @UName
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_qryQM_GetUserRoleAndName] TO PUBLIC
    AS [dbo];

