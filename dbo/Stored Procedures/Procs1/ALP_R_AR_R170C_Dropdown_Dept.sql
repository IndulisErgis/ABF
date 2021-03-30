


CREATE PROCEDURE [dbo].[ALP_R_AR_R170C_Dropdown_Dept] 
AS
BEGIN
SET NOCOUNT ON;

--Seperate Dropdown needed for 170C because '<>' brackets needed around all to work with function

-- Create a Temp table with Branch varchar(255)
CREATE TABLE #ALP_R_AR_R171B_Dropdown_Dept(Dept varchar(10))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_AR_R171B_Dropdown_Dept(Dept) Values ('<ALL>')

-- Append data
INSERT INTO #ALP_R_AR_R171B_Dropdown_Dept 
	SELECT Dept FROM ALP_tblArAlpDept GROUP BY Dept ORDER BY Dept

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_R171B_Dropdown_Dept

DROP TABLE #ALP_R_AR_R171B_Dropdown_Dept
END