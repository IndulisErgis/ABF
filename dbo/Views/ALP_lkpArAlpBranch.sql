
CREATE VIEW dbo.ALP_lkpArAlpBranch
AS
SELECT     TOP 100 PERCENT BranchId, Branch, Name, InactiveYN
FROM         dbo.ALP_tblArAlpBranch
WHERE     (InactiveYN = 0)
ORDER BY Branch