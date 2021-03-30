CREATE  PROCEDURE [dbo].[ALP_CurrentUser]
@UserID varchar(50) OUTPUT,
@WrkStnID pWrkStnID OUTPUT,
@UName varchar(255)='' OUT
AS
--modified to increase Alpine userID length of 50 from 20, mah 05/05/17

set nocount on

Declare @vcUserName varchar(255)
Declare @tiTemp tinyint

/* Must parse out the user name when using NT authentication */
SELECT @vcUserName=SUBSTRING(SUSER_SNAME(),1,255)
SELECT @tiTemp = CHARINDEX('\',@vcUserName)
IF @tiTemp>0
     begin
          SELECT @vcUserName=SUBSTRING(@vcUserName,@tiTemp+1,255) 
end

--SET @UserID = SUBSTRING(@vcUserName,1,20)
SET @UserID = SUBSTRING(@vcUserName,1,50)
SET @WrkStnID = HOST_NAME()
SET @UName = SUSER_SNAME()