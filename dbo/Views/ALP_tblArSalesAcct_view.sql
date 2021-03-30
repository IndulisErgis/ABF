CREATE VIEW dbo.ALP_tblArSalesAcct_view
AS
SELECT     dbo.tblArSalesAcct.*, dbo.ALP_tblArSalesAcct.*
FROM         dbo.ALP_tblArSalesAcct RIGHT OUTER JOIN
                      dbo.tblArSalesAcct ON dbo.ALP_tblArSalesAcct.AlpAcctCode = dbo.tblArSalesAcct.AcctCode