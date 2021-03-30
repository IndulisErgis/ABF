



CREATE PROCEDURE [dbo].[ALP_R_AR_R724E_InvVal_LastCost_CategoryDropDown] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Category varchar(50)
CREATE TABLE #R724CategoryDropdown(Category varchar(50))

-- Append the location ID's from tblInItem
INSERT INTO #R724CategoryDropdown(Category) SELECT DISTINCT ISNULL(ALPCATG,'NO CATEGORY') FROM ALP_tblInItem_view

-- Send it down to the report dataset
SELECT * FROM #R724CategoryDropdown
ORDER BY Category

DELETE FROM #R724CategoryDropdown
DROP TABLE #R724CategoryDropdown

END