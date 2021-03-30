


CREATE PROCEDURE [dbo].[ALP_R_AR_SI_420_Dropdown_Status] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Status varchar(255)
CREATE TABLE #ALP_R_AR_SI_420_Dropdown_Status(Status varchar(20))

-- Append the location ID's from tblArAlpSiteRecBillServ
INSERT INTO #ALP_R_AR_SI_420_Dropdown_Status 
	SELECT Status FROM ALP_tblArAlpSiteRecBillServ GROUP BY Status ORDER BY Status

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_SI_420_Dropdown_Status

DROP TABLE #ALP_R_AR_SI_420_Dropdown_Status
END