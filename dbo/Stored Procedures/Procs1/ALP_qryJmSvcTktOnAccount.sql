CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktOnAccount]  
@ID pCustId, @gArOnAcctInvc pInvoiceNum  
As  
SET NOCOUNT ON  
SELECT ALP_tblArOpenInvoice_view.CustId, 
--Sum(ALP_tblArOpenInvoice_view.Amt) AS OnAcctAmt 
SUM(CASE WHEN ALP_tblArOpenInvoice_view.[RecType] >0 THEN ALP_tblArOpenInvoice_view.[Amt] 
	ELSE ALP_tblArOpenInvoice_view.[Amt] * -1 END  ) AS OnAcctAmt 
FROM ALP_tblArOpenInvoice_view  
WHERE ALP_tblArOpenInvoice_view.InvcNum = @gArOnAcctInvc AND
 ALP_tblArOpenInvoice_view.Status <> 4  
GROUP BY ALP_tblArOpenInvoice_view.CustId  
HAVING ALP_tblArOpenInvoice_view.CustId = @ID