
CREATE VIEW dbo.ALP_lkpJmMarketCode
AS
SELECT     TOP 100 PERCENT MarketCodeId, MarketCode, [Desc]
FROM         dbo.ALP_tblJmMarketCode
ORDER BY MarketCode