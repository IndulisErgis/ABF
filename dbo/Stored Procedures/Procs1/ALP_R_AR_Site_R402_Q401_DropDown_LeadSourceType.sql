

CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R402_Q401_DropDown_LeadSourceType] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with LocID varchar(10)
	CREATE TABLE #R402_Q401Dropdown_LeadSourceType (LeadSourceType varchar(10))

-- Insert into table 1st row as '<ALL>'
	INSERT INTO #R402_Q401Dropdown_LeadSourceType (LeadSourceType) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
	INSERT INTO #R402_Q401Dropdown_LeadSourceType 
		SELECT LeadSourceType FROM ufxALP_R_AR_Site_Q401() GROUP BY LeadSourceType

-- Send it down to the report dataset
	SELECT * FROM #R402_Q401Dropdown_LeadSourceType ORDER BY LeadSourceType

	--DELETE FROM #R402_Q401Dropdown_LeadSourceType
	DROP TABLE #R402_Q401Dropdown_LeadSourceType

END