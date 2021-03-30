



CREATE PROCEDURE [dbo].[ALP_R_AR_R170C_Dropdown_WorkCode] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Branch varchar(255)
CREATE TABLE #ALP_R_AR_R170C_Dropdown_WorkCode(WorkCode varchar(255))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_AR_R170C_Dropdown_WorkCode(WorkCode) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #ALP_R_AR_R170C_Dropdown_WorkCode 
	SELECT WorkCode FROM ALP_tblJmWorkCode GROUP BY WorkCode ORDER BY WorkCode

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_R170C_Dropdown_WorkCode

DROP TABLE #ALP_R_AR_R170C_Dropdown_WorkCode
END