

CREATE PROCEDURE [dbo].[ALP_R_AR_In_R751B_Dropdown_VendorID] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Branch varchar(255)
CREATE TABLE #ALP_R_AR_In_R751B_VendorIDDropdown(VendorID varchar(10))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_AR_In_R751B_VendorIDDropdown(VendorID) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #ALP_R_AR_In_R751B_VendorIDDropdown SELECT VendorID FROM tblAPVendor

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_In_R751B_VendorIDDropdown
--DELETE FROM #ALP_R_AR_In_R751B_VendorIDDropdown
DROP TABLE #ALP_R_AR_In_R751B_VendorIDDropdown
END