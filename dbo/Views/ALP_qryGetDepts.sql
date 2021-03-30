
CREATE VIEW dbo.ALP_qryGetDepts
AS
SELECT     TOP 100 PERCENT Dept, Name
FROM         dbo.ALP_tblArAlpDept
ORDER BY Dept