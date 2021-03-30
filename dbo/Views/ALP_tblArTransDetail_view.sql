CREATE VIEW dbo.ALP_tblArTransDetail_view
AS
SELECT     dbo.tblArTransDetail.*, dbo.ALP_tblArTransDetail.*
FROM         dbo.ALP_tblArTransDetail RIGHT OUTER JOIN
                      dbo.tblArTransDetail ON dbo.ALP_tblArTransDetail.AlpTransID = dbo.tblArTransDetail.TransID AND 
                      dbo.ALP_tblArTransDetail.AlpEntryNum = dbo.tblArTransDetail.EntryNum