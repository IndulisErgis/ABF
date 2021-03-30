CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktOnAccount_ORIG]  
@ID pCustId, @gArOnAcctInvc pInvoiceNum  
As  
SET NOCOUNT ON  
SELECT ALP_tblArOpenInvoice_view.CustId, Sum(ALP_tblArOpenInvoice_view.Amt) AS OnAcctAmt  
FROM ALP_tblArOpenInvoice_view  
WHERE ALP_tblArOpenInvoice_view.InvcNum = @gArOnAcctInvc AND
 ALP_tblArOpenInvoice_view.Status <> 4  
GROUP BY ALP_tblArOpenInvoice_view.CustId  
HAVING ALP_tblArOpenInvoice_view.CustId = @ID