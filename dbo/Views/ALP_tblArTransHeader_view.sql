CREATE VIEW dbo.ALP_tblArTransHeader_view  
AS  
SELECT   dbo.ALP_tblArTransHeader.* ,  dbo.tblArTransHeader.* 
FROM     dbo.ALP_tblArTransHeader RIGHT OUTER JOIN dbo.tblArTransHeader 
		ON dbo.ALP_tblArTransHeader.AlpTransId = dbo.tblArTransHeader.TransId