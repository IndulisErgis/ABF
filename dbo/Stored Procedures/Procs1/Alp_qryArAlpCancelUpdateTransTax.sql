CREATE Procedure dbo.Alp_qryArAlpCancelUpdateTransTax    
@ID varchar(10)    
AS    
SET NOCOUNT ON    
SELECT tblArTransHeader.TransId, tblArTransHeader.TaxGrpID, tblArTransHeader.TaxableYN, tblArTransHeader.TaxClassMisc,   
tblArTransHeader.TaxSubtotal,    tblArTransHeader.NonTaxSubtotal, tblArTransHeader.SalesTax,  
 tblArTransHeader.TaxSubtotalFgn, tblArTransHeader.NonTaxSubtotalFgn,     
 tblArTransHeader.SalesTaxFgn, tblArTransHeader.TaxAmtAdj, tblArTransHeader.TaxAmtAdjFgn    ,tblArTransHeader .WhseId 
FROM tblArTransHeader    
WHERE tblArTransHeader.TransId = @ID