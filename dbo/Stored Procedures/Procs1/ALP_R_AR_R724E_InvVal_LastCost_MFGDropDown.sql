

CREATE PROCEDURE [dbo].[ALP_R_AR_R724E_InvVal_LastCost_MFGDropDown] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with ItemMFG varchar(50)
CREATE TABLE #R724MFGDropdown(ItemMFG varchar(50))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #R724MFGDropdown (ItemMFG) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #R724MFGDropdown SELECT DISTINCT ALPMFG FROM ALP_tblInItem_view

-- Send it down to the report dataset
SELECT * FROM #R724MFGDropdown
ORDER BY ItemMFG

DELETE FROM #R724MFGDropdown
DROP TABLE #R724MFGDropdown

END