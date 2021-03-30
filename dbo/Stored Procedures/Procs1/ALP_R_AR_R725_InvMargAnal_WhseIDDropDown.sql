
CREATE PROCEDURE [dbo].[ALP_R_AR_R725_InvMargAnal_WhseIDDropDown] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with LocID varchar(10)
CREATE TABLE #R725Dropdown(LocID varchar(10))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #R725Dropdown (LocID) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #R725Dropdown SELECT LocID FROM tblInLoc

-- Send it down to the report dataset
SELECT * FROM #R725Dropdown

DELETE FROM #R725Dropdown
DROP TABLE #R725Dropdown

END