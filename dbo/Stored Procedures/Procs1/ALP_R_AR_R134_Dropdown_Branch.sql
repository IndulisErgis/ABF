


CREATE PROCEDURE [dbo].[ALP_R_AR_R134_Dropdown_Branch] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Branch varchar(255)
CREATE TABLE #ALP_R_AR_R134_Dropdown_Branch(Branch varchar(255))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_AR_R134_Dropdown_Branch(Branch) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #ALP_R_AR_R134_Dropdown_Branch 
	SELECT Branch FROM ALP_tblArAlpBranch GROUP BY Branch ORDER BY Branch

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_R134_Dropdown_Branch

DROP TABLE #ALP_R_AR_R134_Dropdown_Branch
END