CREATE Procedure dbo.Alp_qryArAlpAppendCreditMemoTax    
@sTransId pTransId, @ID pTransId    
AS    
DECLARE @TransIdExist int;
SET NOCOUNT ON    
SELECT @TransIdExist=COUNT (*) FROM tblArTransTax WHERE TransId =@ID 
IF(@TransIdExist=0)
BEGIN
INSERT INTO tblArTransTax ( TransId, TaxLocID, TaxClass, [Level], TaxAmt, TaxAmtFgn, Taxable, TaxableFgn, NonTaxable, NonTaxableFgn, LiabilityAcct )    
SELECT @sTransId, tblArTransTax.TaxLocID, tblArTransTax.TaxClass, tblArTransTax.[Level], tblArTransTax.TaxAmt, tblArTransTax.TaxAmtFgn,    
 tblArTransTax.Taxable, tblArTransTax.TaxableFgn, tblArTransTax.NonTaxable, tblArTransTax.NonTaxableFgn, tblArTransTax.LiabilityAcct    
FROM tblArTransTax    
WHERE tblArTransTax.TransId = @ID
END