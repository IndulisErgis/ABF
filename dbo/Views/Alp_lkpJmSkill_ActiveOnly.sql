CREATE VIEW [dbo].[Alp_lkpJmSkill_ActiveOnly]  
AS  
SELECT SkillId, Skill, [Desc], Comments, InactiveYN  
FROM dbo.Alp_tblJmSkill  
WHERE (InactiveYN = 0)