
CREATE VIEW dbo.ALP_lkpArAlpRequiredUDFs
AS
SELECT     COUNT(UDFId) AS [Count]
FROM         dbo.ALP_tblArAlpUDF
GROUP BY RequiredYN
HAVING      (RequiredYN = - 1)