CREATE VIEW dbo.ALP_lkpArAlpSiteUDFs
AS
SELECT     COUNT(dbo.ALP_tblArAlpUDF.UDFId) AS [Count], dbo.ALP_tblArAlpSiteUdf.SiteId
FROM         dbo.ALP_tblArAlpUDF INNER JOIN
                      dbo.ALP_tblArAlpSiteUdf ON dbo.ALP_tblArAlpUDF.UDFId = dbo.ALP_tblArAlpSiteUdf.UDFId
WHERE     (dbo.ALP_tblArAlpUDF.RequiredYN = - 1)
GROUP BY dbo.ALP_tblArAlpSiteUdf.SiteId