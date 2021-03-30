
CREATE VIEW [dbo].[ALP_lkpJmBranchId]
AS
SELECT     TOP 100 PERCENT BranchId, Branch, Name
FROM         dbo.ALP_tblArAlpBranch
ORDER BY Branch