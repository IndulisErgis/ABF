


CREATE PROCEDURE [dbo].[ALP_R_AR_R159_DropDownForTech]
AS
BEGIN
SET NOCOUNT ON;

-- Create a Temp table with Branch varchar(255)
CREATE TABLE #R159_Dropdown(Tech varchar(5))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #R159_Dropdown (Tech) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #R159_Dropdown 
SELECT Tech FROM ALP_tblJmTech WHERE InactiveYN = '0' ORDER BY Tech

-- Send it down to the report dataset
SELECT * FROM #R159_Dropdown

DELETE FROM #R159_Dropdown
DROP TABLE #R159_Dropdown

END