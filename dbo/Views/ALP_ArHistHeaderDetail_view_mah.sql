CREATE VIEW dbo.ALP_ArHistHeaderDetail_view_mah
AS  
SELECT     dbo.trav_ArHistHeaderDetail_view.*, dbo.ALP_tblArHistDetail.*  
FROM       dbo.trav_ArHistHeaderDetail_view 
				LEFT OUTER JOIN dbo.ALP_tblArHistDetail 
                      ON dbo.ALP_tblArHistDetail.AlpPostRun = dbo.trav_ArHistHeaderDetail_view.PostRun AND   
                      dbo.ALP_tblArHistDetail.AlpTransID = dbo.trav_ArHistHeaderDetail_view.TransId AND   
                      dbo.ALP_tblArHistDetail.AlpEntryNum = dbo.trav_ArHistHeaderDetail_view.EntryNum