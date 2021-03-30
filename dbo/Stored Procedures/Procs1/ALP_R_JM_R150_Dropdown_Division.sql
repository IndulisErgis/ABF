

CREATE PROCEDURE [dbo].[ALP_R_JM_R150_Dropdown_Division] 
AS
BEGIN
SET NOCOUNT ON;
--provides market options for report dropdown - 04/07/2015 - ER

-- Create a Temp table with DivisionId and Name
CREATE TABLE #ALP_R_JM_R150_Dropdown_Division(DivisionId int,Name varchar(255))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_JM_R150_Dropdown_Division(DivisionId,Name) Values (0,'<ALL>')

-- Append the location ID's from ALP_tblArAlpDivision
INSERT INTO #ALP_R_JM_R150_Dropdown_Division 
	SELECT DivisionId, Name
	FROM ALP_tblArAlpDivision 

-- Send it down to the report dataset
SELECT * FROM #ALP_R_JM_R150_Dropdown_Division

DROP TABLE #ALP_R_JM_R150_Dropdown_Division
END