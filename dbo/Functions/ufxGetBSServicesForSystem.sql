CREATE FUNCTION [dbo].[ufxGetBSServicesForSystem] 
/* This function is used by CSBS processing in clsCSBS.  
   It finds all active, monitored ( Service Type = 4) services for a system,
   and translates them to standard Central Station Services using the CS tables. 
*/
	(
		@SystemID int = null
	)  
RETURNS Table
AS  
RETURN ( SELECT 
		RecSvcId = RBS.RecBillServId,
		RBS.ServiceID,
		CSV.SvcCode,
		RBS.ServiceStartDate,
		RBS.ActivePrice
	FROM ALP_tblArAlpSiteRecBillServ RBS
		INNER JOIN ALP_tblCSsvcperbillingCode CSBC
			ON RBS.ServiceID = CSBC.ItemID
		INNER JOIN ALP_tblCSServices CSV	
			ON CSBC.CSSvcId = CSV.CSSvcId
	WHERE ((RBS.SysId = @SystemID) 
		AND (RBS.ServiceType =4)
		AND (RBS.Status = 'Active'))
	)
GO
GRANT SELECT
    ON OBJECT::[dbo].[ufxGetBSServicesForSystem] TO PUBLIC
    AS [dbo];

