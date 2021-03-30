CREATE VIEW dbo.ALP_tblArCashRcptDetail_view
AS
SELECT     dbo.tblArCashRcptDetail.*, dbo.ALP_tblArCashRcptDetail.*
FROM         dbo.tblArCashRcptDetail LEFT OUTER JOIN
                      dbo.ALP_tblArCashRcptDetail ON dbo.tblArCashRcptDetail.RcptDetailID = dbo.ALP_tblArCashRcptDetail.AlpRcptDetailID