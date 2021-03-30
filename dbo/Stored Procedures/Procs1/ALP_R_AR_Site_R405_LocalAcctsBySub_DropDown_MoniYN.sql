
CREATE PROCEDURE [dbo].[ALP_R_AR_Site_R405_LocalAcctsBySub_DropDown_MoniYN] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with LocID varchar(10)
	CREATE TABLE #R405_Dropdown_MoniYN (MoniYN varchar(8))

---- Insert into table 1st row as '<ALL>'
	INSERT INTO #R405_Dropdown_MoniYN (MoniYN) Values ('0')	
	INSERT INTO #R405_Dropdown_MoniYN (MoniYN) Values ('1')	
	INSERT INTO #R405_Dropdown_MoniYN (MoniYN) Values ('2')	
	
	---- Append the location ID's from tblInItemLoc
	--INSERT INTO #R405_Dropdown_MoniYN 
	--	SELECT MoniYN FROM ufxALP_R_AR_Site_R405_MoniYN() 
		
---- Send it down to the report dataset
	SELECT MoniYN FROM #R405_Dropdown_MoniYN ORDER BY MoniYN

	--DELETE FROM #R402_Q401Dropdown_Subdiv
	DROP TABLE #R405_Dropdown_MoniYN

END