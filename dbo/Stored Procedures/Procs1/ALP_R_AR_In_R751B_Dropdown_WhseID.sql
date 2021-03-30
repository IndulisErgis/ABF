
Create PROCEDURE [dbo].[ALP_R_AR_In_R751B_Dropdown_WhseID] 
AS
BEGIN
SET NOCOUNT ON;
-- Create a Temp table with Whse ID varchar(10)
CREATE TABLE #R751BDropdown(LocID varchar(10))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #R751BDropdown (LocID) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #R751BDropdown SELECT LocID FROM tblInLoc

-- Send it down to the report dataset
SELECT * FROM #R751BDropdown

DROP TABLE #R751BDropdown

END