



CREATE PROCEDURE [dbo].[ALP_R_AR_SI_R420_Dropdown_ServiceVndr] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with ServiceVndr varchar(255)
CREATE TABLE #ALP_R_AR_SI_R420_Dropdown_ServiceVndr(ServiceVndr varchar(12))

-- Append the location ID's from ALP_tblInItem
INSERT INTO #ALP_R_AR_SI_R420_Dropdown_ServiceVndr
	SELECT AlpMFG FROM ALP_tblInItem 
	INNER JOIN ALP_tblArAlpSiteRecBillServ
	ON ALP_tblArAlpSiteRecBillServ.ServiceID = ALP_tblInItem.AlpItemId
	GROUP BY AlpMFG ORDER BY AlpMFG
	

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_SI_R420_Dropdown_ServiceVndr

DROP TABLE #ALP_R_AR_SI_R420_Dropdown_ServiceVndr
END