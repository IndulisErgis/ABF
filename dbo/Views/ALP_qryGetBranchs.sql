
CREATE VIEW dbo.ALP_qryGetBranchs
AS
SELECT     TOP 100 PERCENT Branch, Name
FROM         dbo.ALP_tblArAlpBranch
ORDER BY Branch