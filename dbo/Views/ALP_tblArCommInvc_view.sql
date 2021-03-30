CREATE VIEW dbo.ALP_tblArCommInvc_view
AS
SELECT     dbo.tblArCommInvc.*, dbo.ALP_tblArCommInvc.*
FROM         dbo.ALP_tblArCommInvc RIGHT OUTER JOIN
                      dbo.tblArCommInvc ON dbo.ALP_tblArCommInvc.AlpCounter = dbo.tblArCommInvc.Counter