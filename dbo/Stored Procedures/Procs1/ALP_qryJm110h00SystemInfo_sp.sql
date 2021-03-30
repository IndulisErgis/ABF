
CREATE Procedure [dbo].[ALP_qryJm110h00SystemInfo_sp]
/* RecordSource for System Info subform of Control Center */
	(
	@SysID int = null	
	)
As
	set nocount on
	SELECT SS.SysId, SS.SysDesc, 
		SS.CentralId, SS.InstallDate, SS.AlarmId, 
		SS.WarrExpires, cs.Central
	FROM ALP_tblArAlpSiteSys SS (NOLOCK) LEFT JOIN ALP_tblArAlpCentralStation cs (NOLOCK)
		ON SS.CentralId = cs.CentralId
	WHERE SS.Sysid = @Sysid
	ORDER BY SS.SysId
	return