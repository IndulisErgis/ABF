

CREATE PROCEDURE [dbo].[ALP_R_AR_MonthsOfTheYear]
AS
BEGIN
SET NOCOUNT ON;

CREATE TABLE #ALP_R_AR_Months
(
[Month] int, 
[MonthName] varchar(10)
)
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('January','1')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('February','2')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('March','3')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('April','4')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('May','5')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('June','6')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('July','7')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('August','8')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('September','9')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('October','10')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('November','11')
INSERT INTO #ALP_R_AR_Months(MonthName,Month) Values ('December','12')

-- Append the location ID's from tblInItemLoc
--INSERT INTO #ALP_R_AR_Months
--	SELECT UsrFld1 FROM tblInItem GROUP BY UsrFld1 ORDER BY UsrFld1

-- Send it down to the report dataset
SELECT * FROM #ALP_R_AR_Months
--DELETE FROM #ALP_R_AR_In_R751B_VendorIDDropdown
DROP TABLE #ALP_R_AR_Months
END