
CREATE VIEW dbo.ALP_lkpJmSvcTktSkillId AS 
SELECT SkillId, Skill, [Desc], InactiveYN FROM dbo.ALP_tblJmSkill WHERE (InactiveYN = 0)