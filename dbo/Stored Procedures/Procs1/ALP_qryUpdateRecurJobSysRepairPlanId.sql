
CREATE PROCEDURE [dbo].[ALP_qryUpdateRecurJobSysRepairPlanId]	
@RepPlanId int,
@SysId int,@CreateDate datetime
AS
Update ALP_tblJmSvcTkt set RepPlanId=@RepPlanId
WHERE RepPlanId Is Null and SysId=@SysId and CreateDate=@CreateDate