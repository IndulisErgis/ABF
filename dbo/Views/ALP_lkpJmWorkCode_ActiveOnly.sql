Create View [dbo].[ALP_lkpJmWorkCode_ActiveOnly] as 
SELECT     TOP 100 PERCENT WorkCodeId, WorkCode, [Desc], InactiveYN, DfltSkillId
FROM         dbo.ALP_tblJmWorkCode
WHERE     (InactiveYN = 0)
ORDER BY WorkCode