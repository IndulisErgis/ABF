


CREATE PROCEDURE [dbo].[ALP_R_AR_In_R751B_Dropdown_MFG] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Branch varchar(255)
CREATE TABLE #ALP_R_AR_In_R751B_MFGDropdown(MFG varchar(12))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_AR_In_R751B_MFGDropdown(MFG) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #ALP_R_AR_In_R751B_MFGDropdown 
	--Modified to use ALPMFG instead of UsrFld1 - 01/08/16 - ER
	SELECT AlpMFG FROM ALP_tblInItem_view GROUP BY AlpMFG ORDER BY AlpMFG

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_In_R751B_MFGDropdown

DROP TABLE #ALP_R_AR_In_R751B_MFGDropdown
END