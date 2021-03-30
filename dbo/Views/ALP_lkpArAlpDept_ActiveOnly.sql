
CREATE VIEW dbo.ALP_lkpArAlpDept_ActiveOnly
AS
SELECT TOP 100 PERCENT DeptId, Dept, [Name], InactiveYN
FROM dbo.ALP_tblArAlpDept
WHERE (InactiveYN = 0)
ORDER BY Dept