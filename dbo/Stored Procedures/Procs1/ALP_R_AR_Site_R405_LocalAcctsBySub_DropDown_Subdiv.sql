

CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R405_LocalAcctsBySub_DropDown_Subdiv] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with LocID varchar(10)
	CREATE TABLE #R405_Dropdown_Subdiv (Subdiv varchar(10))

-- Insert into table 1st row as '<ALL>'
	INSERT INTO #R405_Dropdown_Subdiv (Subdiv) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
	INSERT INTO #R405_Dropdown_Subdiv 
		SELECT Subdiv FROM ufxALP_R_AR_Site_Q401() GROUP BY Subdiv

-- Send it down to the report dataset
	SELECT Subdiv FROM #R405_Dropdown_Subdiv ORDER BY Subdiv

	--DELETE FROM #R402_Q401Dropdown_Subdiv
	DROP TABLE #R405_Dropdown_Subdiv

END