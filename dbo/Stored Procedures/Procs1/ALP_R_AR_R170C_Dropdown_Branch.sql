


CREATE PROCEDURE [dbo].[ALP_R_AR_R170C_Dropdown_Branch] 
AS
BEGIN
SET NOCOUNT ON;

--Seperate Dropdown needed for 170C because '<>' brackets needed around all to work with function

-- Create a Temp table with Branch varchar(255)
CREATE TABLE #ALP_R_AR_R171B_Dropdown_Branch(Branch varchar(255))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_AR_R171B_Dropdown_Branch(Branch) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #ALP_R_AR_R171B_Dropdown_Branch 
	SELECT Branch FROM ALP_tblArAlpBranch GROUP BY Branch ORDER BY Branch

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_R171B_Dropdown_Branch

DROP TABLE #ALP_R_AR_R171B_Dropdown_Branch
END