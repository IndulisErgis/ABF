

CREATE PROCEDURE [dbo].[ALP_R_AR_R171B_Dropdown_Tech] 
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Tech
CREATE TABLE #ALP_R_AR_R171B_Dropdown_Tech(Tech varchar(3))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_AR_R171B_Dropdown_Tech(Tech) Values ('ALL')

-- Append data
INSERT INTO #ALP_R_AR_R171B_Dropdown_Tech 
	SELECT Tech FROM ALP_tblJmTech GROUP BY Tech ORDER BY Tech

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_R171B_Dropdown_Tech

DROP TABLE #ALP_R_AR_R171B_Dropdown_Tech
END