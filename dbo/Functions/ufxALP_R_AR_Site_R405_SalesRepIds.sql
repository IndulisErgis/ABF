CREATE FUNCTION [dbo].[ufxALP_R_AR_Site_R405_SalesRepIds] ()
RETURNS TABLE 
AS
RETURN 
(
	SELECT SalesRepId1
	
	FROM ALP_tblArAlpSite
	
	WHERE SalesRepId1 is not null	
	
	Group BY SalesRepId1


)