CREATE VIEW [dbo].[ALP_ArHistHeaderDetail_view]
AS
SELECT     dbo.ALP_tblArHistDetail.*, dbo.trav_ArHistHeaderDetail_view.*  
FROM       dbo.trav_ArHistHeaderDetail_view 
				LEFT OUTER JOIN dbo.ALP_tblArHistDetail
                      ON
                      --commented out join on AlpPostRun to allow AlarmID to have values - 3/18/15 - ER & MAH
                      --dbo.ALP_tblArHistDetail.AlpPostRun = dbo.trav_ArHistHeaderDetail_view.PostRun AND   
                      dbo.ALP_tblArHistDetail.AlpTransID = dbo.trav_ArHistHeaderDetail_view.TransId AND   
                      dbo.ALP_tblArHistDetail.AlpEntryNum = dbo.trav_ArHistHeaderDetail_view.EntryNum