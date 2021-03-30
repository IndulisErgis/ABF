
CREATE VIEW dbo.ALP_tblArHistHeader_view  
AS  
SELECT     dbo.ALP_tblArHistHeader.* , dbo.tblArHistHeader.* 
FROM         dbo.ALP_tblArHistHeader RIGHT OUTER JOIN  
                      dbo.tblArHistHeader 
                      ON dbo.ALP_tblArHistHeader.AlpPostRun = dbo.tblArHistHeader.PostRun 
                      AND dbo.ALP_tblArHistHeader.AlpTransId = dbo.tblArHistHeader.TransId