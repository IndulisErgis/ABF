CREATE FUNCTION [dbo].[ufxGetBSServicesForTransmitter] 
	(
		@SystemID int = null
	)  
RETURNS Table
AS  
RETURN ( SELECT 
		RecSvcId = RBS.RecBillServId,
		RBS.ServiceID
	FROM ALP_tblArAlpSiteRecBillServ RBS
	WHERE ((RBS.SysId = @SystemID) 
		AND (RBS.ServiceType =4)
		AND (RBS.Status = 'Active'))
	)
GO
GRANT SELECT
    ON OBJECT::[dbo].[ufxGetBSServicesForTransmitter] TO PUBLIC
    AS [dbo];

