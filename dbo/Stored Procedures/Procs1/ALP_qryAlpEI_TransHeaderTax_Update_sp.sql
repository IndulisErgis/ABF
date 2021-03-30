CREATE PROCEDURE [dbo].[ALP_qryAlpEI_TransHeaderTax_Update_sp](    
  --For use only by EI, when updating calculated total Tax to be inserted into TRansHeader
 @pTransId pTransId,     
 @pSalesTax pDec  ,  
 @pSalesTaxFgn pDec  
)AS    
BEGIN    
   UPDATE tblArTransHeader 
   SET SalesTax = CASE WHEN TransType >= 0 THEN @pSalesTax ELSE @pSalesTax * -1 END,
   SalesTaxFgn = CASE WHEN  TransType >= 0 THEN @pSalesTaxFgn ELSE @pSalesTaxFgn * -1 END
   WHERE tblArTransHeader.TransId =  @pTransId  
END