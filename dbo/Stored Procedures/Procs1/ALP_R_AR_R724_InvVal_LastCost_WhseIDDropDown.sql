CREATE PROCEDURE [dbo].[ALP_R_AR_R724_InvVal_LastCost_WhseIDDropDown] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with LocID varchar(10)
CREATE TABLE #R724Dropdown(LocID varchar(10))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #R724Dropdown (LocID) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #R724Dropdown SELECT LocID FROM tblInLoc

-- Send it down to the report dataset
SELECT * FROM #R724Dropdown

DELETE FROM #R724Dropdown
DROP TABLE #R724Dropdown

END