CREATE VIEW dbo.Alp_lkpArAlpSiteRecJobTech  
AS  
SELECT     TechId, Tech, [Name], BranchId, DeptId  
FROM         dbo.Alp_tblJmTech  
WHERE     (InactiveYN = 0)