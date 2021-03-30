CREATE VIEW dbo.ALP_lkpArAlpCentralStation
AS
SELECT     TOP (100) PERCENT Central, Name, CentralId
FROM         dbo.ALP_tblArAlpCentralStation
ORDER BY Central