
CREATE VIEW dbo.ALP_lkpJmSvcTktDeptId AS 
SELECT DeptId, Dept, Name, InactiveYN, GlSegId FROM dbo.ALP_tblArAlpDept WHERE (InactiveYN = 0)