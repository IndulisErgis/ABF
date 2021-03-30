

CREATE PROCEDURE [dbo].[ALP_R_AR_ABF_R102C_DropDownForBranch]
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Branch varchar(255)
CREATE TABLE #R102C_Branch_Dropdown(Branch varchar(255))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #R102C_Branch_Dropdown (Branch) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #R102C_Branch_Dropdown SELECT Branch FROM ALP_tblArAlpBranch

-- Send it down to the report dataset
SELECT * FROM #R102C_Branch_Dropdown

DELETE FROM #R102C_Branch_Dropdown
DROP TABLE #R102C_Branch_Dropdown

END