





CREATE PROCEDURE [dbo].[ALP_R_AR_In_R751B_Dropdown_CATG] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Branch varchar(255)
CREATE TABLE #ALP_R_AR_In_R751B_CATGDropdown(CATG varchar(12))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_AR_In_R751B_CATGDropdown(CATG) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #ALP_R_AR_In_R751B_CATGDropdown 
	--Modified to use ALPMFG instead of UsrFld1 - 01/08/16 - ER
	SELECT AlpCATG FROM ALP_tblInItem_view 
	GROUP BY AlpCATG ORDER BY AlpCATG

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_In_R751B_CATGDropdown

DROP TABLE #ALP_R_AR_In_R751B_CATGDropdown
END