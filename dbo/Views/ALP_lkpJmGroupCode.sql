

CREATE VIEW [dbo].[ALP_lkpJmGroupCode]
AS
SELECT     TOP 100 PERCENT GroupCode
FROM         dbo.tblArCust
GROUP BY GroupCode
ORDER BY GroupCode