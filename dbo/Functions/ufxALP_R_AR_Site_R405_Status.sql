CREATE FUNCTION [dbo].[ufxALP_R_AR_Site_R405_Status] ()
RETURNS TABLE 
AS
RETURN 
(
	SELECT Status
	FROM ALP_tblArAlpSite
	
	WHERE Status is not null	
	
	GROUP BY Status


)