
CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R405_LocalAcctsBySub_DropDown_SalesRepID] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with LocID varchar(10)
	CREATE TABLE #R405_Dropdown_SalesRepID (SalesRepID varchar(5))

---- Insert into table 1st row as '<ALL>'
	INSERT INTO #R405_Dropdown_SalesRepID (SalesRepID) Values ('<ALL>')

---- Append the location ID's from tblInItemLoc
	INSERT INTO #R405_Dropdown_SalesRepID 
		SELECT SalesRepID1 FROM ufxALP_R_AR_Site_R405_SalesRepIDs() 
		
---- Send it down to the report dataset
	SELECT SalesRepID FROM #R405_Dropdown_SalesRepID ORDER BY SalesRepID

	--DELETE FROM #R402_Q401Dropdown_Subdiv
	DROP TABLE #R405_Dropdown_SalesRepID

END