

CREATE PROCEDURE [dbo].[ALP_R_AR_AccessReports_GroupDropDown] 
AS
BEGIN

-- Create a Temp table with GroupLocID varchar(10)
CREATE TABLE #ALP_R_AR_AccessReportsGroupDropDown(ReportGroup varchar(15))

-- Insert into table 1st row as '<ALL>'
INSERT INTO #ALP_R_AR_AccessReportsGroupDropDown (ReportGroup) Values ('<ALL>')

-- Append the location ID's from tblInItemLoc
INSERT INTO #ALP_R_AR_AccessReportsGroupDropDown 
SELECT distinct AR.ReportGroup 
FROM tblALP_R_AccessReports as AR

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_AccessReportsGroupDropDown

DROP TABLE #ALP_R_AR_AccessReportsGroupDropDown

END