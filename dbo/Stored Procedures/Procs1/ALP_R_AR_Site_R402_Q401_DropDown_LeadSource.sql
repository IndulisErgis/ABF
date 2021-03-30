

CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R402_Q401_DropDown_LeadSource] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with LocID varchar(10)
	CREATE TABLE #R402_Q401Dropdown_LeadSource (LeadSource varchar(10))

-- Insert into table 1st row as '<ALL>'
	INSERT INTO #R402_Q401Dropdown_LeadSource (LeadSource) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
	INSERT INTO #R402_Q401Dropdown_LeadSource 
		SELECT LeadSource FROM ufxALP_R_AR_Site_Q401() GROUP BY LeadSource

-- Send it down to the report dataset
	SELECT * FROM #R402_Q401Dropdown_LeadSource ORDER BY LeadSource

	DELETE FROM #R402_Q401Dropdown_LeadSource
	DROP TABLE #R402_Q401Dropdown_LeadSource

END