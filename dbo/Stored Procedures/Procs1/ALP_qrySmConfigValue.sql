Create PROCEDURE [dbo].[ALP_qrySmConfigValue]
AS
Select * from  tblSmConfigValue SmConfigVal inner join SYS.dbo.tblSmConfig SmConfig on 
SmConfigVal.ConfigRef=SmConfig.ConfigRef
where APPid ='JM' and  ConfigId = 'ShowPointsConfirmYN'