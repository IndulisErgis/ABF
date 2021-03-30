  
CREATE PROCEDURE dbo.ALP_ArTransPost_RemoveTrans_proc  
AS  
BEGIN TRY  
 DELETE dbo.ALP_tblArTransHeader  
  FROM dbo.ALP_tblArTransHeader  
  INNER JOIN #PostTransList l ON dbo.ALP_tblArTransHeader.AlpTransId = l.TransId  
  
 DELETE dbo.ALP_tblArTransDetail  
  FROM dbo.ALP_tblArTransDetail  
  INNER JOIN #PostTransList l ON dbo.ALP_tblArTransDetail.AlpTransID  = l.TransId  
  
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH