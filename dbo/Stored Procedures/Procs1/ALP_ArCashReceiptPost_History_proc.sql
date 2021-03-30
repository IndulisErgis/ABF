 
  
CREATE PROCEDURE [dbo].[ALP_ArCashReceiptPost_History_proc]  
AS  
BEGIN TRY  
 DECLARE @PostRun pPostRun, @WrkStnDate datetime  
  
 --Retrieve global values  
 SELECT @PostRun = Cast([Value] AS nvarchar) FROM #GlobalValues WHERE [Key] = 'PostRun'  
 SELECT @WrkStnDate = Cast([Value] AS datetime) FROM #GlobalValues WHERE [Key] = 'WrkStnDate'  
  
 IF @PostRun IS NULL OR @WrkStnDate IS NULL   
 BEGIN  
  RAISERROR(90025,16,1)  
 END  
  
 --append prepayments into payment history  
 INSERT dbo.ALP_tblArHistPmt (AlpCounter  ,AlpSiteID,AlpComment)   
 SELECT histPmt.Counter, alpD.AlpSiteID,alpd.AlpComment 
 FROM dbo.tblArCashRcptHeader h   
 INNER JOIN dbo.tblArCashRcptDetail d ON h.RcptHeaderID = d.RcptHeaderID   
 INNER JOIN dbo.ALP_tblArCashRcptDetail alpD ON alpD.AlpRcptDetailID = d.RcptDetailID 
 INNER JOIN dbo.tblArHistPmt histPmt ON histPmt .TransId = d.RcptDetailID 
 INNER JOIN #PostTransList l ON h.RcptHeaderID = l.TransId   
 --mah 03/30/15:
 WHERE histPmt.PostRun = @PostRun
 --LEFT JOIN dbo.tblArPmtMethod p on h.PmtMethodId = p.PmtMethodId  
 --LEFT JOIN dbo.tblSmBankAcct b on p.BankId = b.BankId  
 --LEFT JOIN dbo.tblArCust c on h.CustId = c.CustId  
 --LEFT JOIN dbo.tblArDistCode dc on d.DistCode = dc.DistCode  
  
END TRY  
BEGIN CATCH  
 EXEC dbo.trav_RaiseError_proc  
END CATCH