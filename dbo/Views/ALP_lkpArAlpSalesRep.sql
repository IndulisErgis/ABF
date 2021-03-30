
CREATE VIEW dbo.ALP_lkpArAlpSalesRep
AS
SELECT     SalesRepID, Name
FROM         dbo.ALP_tblArSalesRep_view
WHERE     (AlpInactiveYN = 0)