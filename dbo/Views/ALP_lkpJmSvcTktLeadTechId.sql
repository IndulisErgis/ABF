
CREATE VIEW dbo.ALP_lkpJmSvcTktLeadTechId
AS
SELECT DISTINCT dbo.ALP_tblJmTech.Tech, dbo.ALP_tblJmTech.Name, dbo.ALP_tblJmTech.TechId, 
	dbo.ALP_tblArAlpBranch.Branch, dbo.ALP_tblArAlpDept.Dept, dbo.ALP_tblJmTechSkills.SkillId
FROM         dbo.ALP_tblJmTech INNER JOIN
                      dbo.ALP_tblJmTechSkills ON dbo.ALP_tblJmTech.TechId = dbo.ALP_tblJmTechSkills.TechId INNER JOIN
                      dbo.ALp_tblArAlpBranch ON dbo.ALP_tblJmTech.BranchId = dbo.ALP_tblArAlpBranch.BranchId INNER JOIN
                      dbo.ALP_tblArAlpDept ON dbo.ALP_tblJmTech.DeptId = dbo.ALP_tblArAlpDept.DeptId
WHERE     (dbo.ALP_tblJmTech.InactiveYN = 0)