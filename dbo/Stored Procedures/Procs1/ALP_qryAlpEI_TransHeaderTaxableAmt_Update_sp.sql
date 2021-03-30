CREATE PROCEDURE [dbo].[ALP_qryAlpEI_TransHeaderTaxableAmt_Update_sp](    
  -- Created by mah on 12/4/15: For use only by EI, when updating calculated total Tax to be inserted into TRansHeader
 @pTransId pTransId,     
 @pTaxableAmt pDec  , 
 @pTaxableAmtFgn pDec  ,  
 @pNonTaxableAmt pDec ,
 @pNonTaxableAmtFgn pDec  
)AS    
BEGIN    
   UPDATE tblArTransHeader 
   SET TaxSubtotal =@pTaxableAmt ,TaxSubtotalFgn = @pTaxableAmtFgn , 
   NonTaxSubtotal = @pNonTaxableAmt ,NonTaxSubtotalFgn = @pNonTaxableAmtFgn
   WHERE tblArTransHeader.TransId =  @pTransId  
END