

CREATE PROCEDURE [dbo].[ALP_R_AR_ABF_R102C_DropDownForDepartment]
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Branch varchar(255)
CREATE TABLE #R102C_Department_Dropdown(Dept varchar(10))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #R102C_Department_Dropdown (Dept) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #R102C_Department_Dropdown SELECT Dept FROM ALP_tblArAlpDept

-- Send it down to the report dataset
SELECT * FROM #R102C_Department_Dropdown

DELETE FROM #R102C_Department_Dropdown
DROP TABLE #R102C_Department_Dropdown

END