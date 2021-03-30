CREATE VIEW dbo.ALP_tblArSalesRep_view
AS
SELECT     dbo.tblArSalesRep.*, dbo.ALP_tblArSalesRep.*
FROM         dbo.ALP_tblArSalesRep RIGHT OUTER JOIN
                      dbo.tblArSalesRep ON dbo.ALP_tblArSalesRep.AlpSalesRepID = dbo.tblArSalesRep.SalesRepID