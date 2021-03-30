CREATE PROCEDURE dbo.ALP_qryArAlpGetTransId @ID pInvoiceNum  
As  
SET NOCOUNT ON  
SELECT ALP_tblArHistHeader_view.TransId, ALP_tblArHistHeader_view.InvcNum  
FROM ALP_tblArHistHeader_view  
WHERE ALP_tblArHistHeader_view.InvcNum = @ID