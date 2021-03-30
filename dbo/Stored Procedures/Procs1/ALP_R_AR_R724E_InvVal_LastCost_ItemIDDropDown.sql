

CREATE PROCEDURE [dbo].[ALP_R_AR_R724E_InvVal_LastCost_ItemIDDropDown] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with ItemID varchar(50)
CREATE TABLE #R724ItemIDDropdown(ItemID varchar(50))

-- Append the location ID's from tblInItemLoc
INSERT INTO #R724ItemIDDropdown SELECT ItemId FROM tblInItem

-- Send it down to the report dataset
SELECT * FROM #R724ItemIDDropdown
ORDER BY ItemID

DELETE FROM #R724ItemIDDropdown
DROP TABLE #R724ItemIDDropdown

END