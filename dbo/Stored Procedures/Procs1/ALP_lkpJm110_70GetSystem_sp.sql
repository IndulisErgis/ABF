
CREATE Procedure [dbo].[ALP_lkpJm110_70GetSystem_sp]
--EFI# 1311 MAH 04/22/04: SIMS Interface - added CentralID to output
	(
		@CustID pCustid = '--NONE--',
		@SiteID int = 0
	)
As
SET NOCOUNT ON
	SELECT ALP_tblArAlpSiteSys.SysId AS ID, 
		ALP_tblArAlpSiteSys.AlarmId AS [Alarm ID], 
		ALP_tblArAlpSiteSys.SysDesc AS Description, 
		ALP_tblArAlpSiteSys.CustId, 
		ALP_tblArAlpSiteSys.SiteId,
		ALP_tblArAlpSiteSys.CentralId
	FROM ALP_tblArAlpSiteSys
	WHERE ((@CustID ='--NONE--' Or @CustID=[custID]) 
		 AND (@SiteID = 0 Or @SiteID=[SiteID])
		 AND (ALP_tblArAlpSiteSys.PulledDate) Is Null)
	ORDER BY ALP_tblArAlpSiteSys.AlarmId DESC;
	return