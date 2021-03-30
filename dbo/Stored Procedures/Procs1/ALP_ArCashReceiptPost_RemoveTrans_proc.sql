 

  
CREATE PROCEDURE [dbo].[ALP_ArCashReceiptPost_RemoveTrans_proc]  
AS  
BEGIN TRY  
  
 DELETE dbo.ALP_tblArCashRcptDetail   
  FROM dbo.ALP_tblArCashRcptDetail alpDtl 
  INNER JOIN  dbo.tblArCashRcptDetail  d ON d.RcptDetailID = alpdtl.AlpRcptDetailID 
  INNER JOIN #PostTransList l ON d.RcptHeaderID = l.TransId   
  
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH