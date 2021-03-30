
CREATE VIEW dbo.ALP_lkpJmFudge
AS
SELECT     FudgeId, FudgeFactor, [Desc], InactiveYN
FROM         dbo.ALP_tblJmFudge
WHERE     (InactiveYN = 0)