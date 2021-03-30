CREATE VIEW dbo.ALP_tblArHistDetail_view  
AS  
SELECT     dbo.ALP_tblArHistDetail.*, dbo.tblArHistDetail.*  
FROM         dbo.tblArHistDetail INNER JOIN tblArHistHeader h ON h.PostRun = dbo.tblArHistDetail.PostRun AND h.TransId = dbo.tblArHistDetail.TransId 
							LEFT OUTER JOIN  
                      dbo.ALP_tblArHistDetail ON dbo.tblArHistDetail.PostRun = dbo.ALP_tblArHistDetail.AlpPostRun AND   
                      dbo.tblArHistDetail.TransID = dbo.ALP_tblArHistDetail.AlpTransID 
                      AND dbo.tblArHistDetail.EntryNum = dbo.ALP_tblArHistDetail.AlpEntryNum