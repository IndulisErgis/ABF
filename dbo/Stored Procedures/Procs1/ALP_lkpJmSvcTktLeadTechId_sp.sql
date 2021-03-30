CREATE PROCEDURE [dbo].[ALP_lkpJmSvcTktLeadTechId_sp]  
--EFI# 1739 MAH 04/29/07 - created  
--EFI# 842 Ravi 11/19/2018 - alter
 (  
 @BranchId int = 0,  
 @DeptId int = 0,  
 @SkillId int = 0  
 )  
AS  
Set NOCOUNT on  
SELECT dbo.ALP_tblJmTech.Tech, dbo.ALP_tblJmTech.[Name], dbo.ALP_tblJmTech.TechId,   
 dbo.ALP_tblArAlpBranch.Branch, dbo.ALP_tblArAlpDept.Dept 
 --Below actvie/inactive logic added by ravi on 16 nov 2018, to fix the bugid 842,
 , CASE WHEN  dbo.ALP_tblJmTech.InactiveYN =1 THEN 'Inactive' WHEN   dbo.ALP_tblJmTech.InactiveYN=0 THEN 'active' END AS InactiveYN
FROM         dbo.ALP_tblJmTech INNER JOIN  
                      dbo.ALP_tblJmTechSkills ON dbo.ALP_tblJmTech.TechId = dbo.ALP_tblJmTechSkills.TechId INNER JOIN  
                      dbo.ALP_tblArAlpBranch ON dbo.ALP_tblJmTech.BranchId = dbo.ALP_tblArAlpBranch.BranchId INNER JOIN  
                      dbo.ALP_tblArAlpDept ON dbo.ALP_tblJmTech.DeptId = dbo.ALP_tblArAlpDept.DeptId  
--WHERE   
--Below line commentted by ravi on 16 nov 2018, to fix the bugid 842,
--(dbo.ALP_tblJmTech.InactiveYN = 0)   AND  


-- ((@BranchID = 0) OR (@BranchID <> 0 AND dbo.ALP_tblJmTech.BranchId = @BranchID))  
-- AND  
-- ((@DeptId = 0) OR (@DeptId <> 0 AND dbo.ALP_tblJmTech.DeptId = @DeptId))  
-- AND  
-- ((@SkillId = 0) OR (@SkillId <> 0 AND dbo.ALP_tblJmTechSkills.SkillId = @SkillId))  
GROUP BY dbo.ALP_tblJmTech.Tech, dbo.ALP_tblJmTech.[Name], dbo.ALP_tblJmTech.TechId,   
 dbo.ALP_tblArAlpBranch.Branch, dbo.ALP_tblArAlpDept.Dept
 , dbo.ALP_tblJmTech .InactiveYN 
ORDER BY dbo.ALP_tblJmTech.Tech, dbo.ALP_tblJmTech.[Name], dbo.ALP_tblJmTech.TechId,   
 dbo.ALP_tblArAlpBranch.Branch, dbo.ALP_tblArAlpDept.Dept