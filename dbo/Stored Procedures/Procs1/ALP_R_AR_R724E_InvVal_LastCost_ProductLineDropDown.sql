

CREATE PROCEDURE [dbo].[ALP_R_AR_R724E_InvVal_LastCost_ProductLineDropDown] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with ProductLine varchar(30)
CREATE TABLE #R724ProductLineDropDown(ProductLine varchar(30))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #R724ProductLineDropDown (ProductLine) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #R724ProductLineDropDown SELECT DISTINCT ProductLine FROM tblInItem

-- Send it down to the report dataset
SELECT * FROM #R724ProductLineDropDown
ORDER BY ProductLine

DELETE FROM #R724ProductLineDropDown
DROP TABLE #R724ProductLineDropDown

END