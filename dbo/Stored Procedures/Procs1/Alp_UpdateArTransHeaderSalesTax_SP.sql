CREATE PROCEDURE [dbo].[Alp_UpdateArTransHeaderSalesTax_SP](    
 -- Modified by ravi on 12/4/15: Update tblArTransTax code commented
 -- Modified by mah on 12/4/15: Entered the Tax adjustment into the TRansHeader
 @pTransId pTransId,     
 @pSalesTax pDec  ,  
 @pSalesTaxFgn pDec  
)AS    
BEGIN    
   UPDATE tblArTransHeader 

   --following code modified by MAH 12/4/15 - to correctly insert the Tax Adjustment amount 
   --		when tax is manually overrriden usinb the JM Ticket screen
   --SET SalesTax =@pSalesTax ,SalesTaxFgn =@pSalesTaxFgn 
   SET SalesTax =@pSalesTax ,SalesTaxFgn =@pSalesTaxFgn,
   TaxAmtAdj = CASE WHEN (@pSalesTax - tblArTransHeader.SalesTax) <> 0 THEN @pSalesTax - tblArTransHeader.SalesTax
		ELSE TaxAmtAdj END, 
   TaxAmtAdjFgn = CASE WHEN (@pSalesTax - tblArTransHeader.SalesTax) <> 0 THEN @pSalesTaxFgn - tblArTransHeader.SalesTaxFgn
		ELSE  TaxAmtAdjFgn END,
   TaxLocAdj = CASE WHEN (@pSalesTax - tblArTransHeader.SalesTax) <> 0 THEN tblSmTaxGroup.LevelOne
		ELSE  TaxLocAdj END , 
	TaxClassAdj = CASE WHEN (@pSalesTax - tblArTransHeader.SalesTax) <> 0 THEN 1 ELSE TaxClassAdj END
   FROM tblArTransHeader INNER JOIN tblSmTaxGroup ON tblArTransHeader.TaxGrpID = tblSmTaxGroup.TaxGrpID    
   WHERE tblArTransHeader.TransId =  @pTransId  
   -- The ticket is always creates one summary tax record for tax level 1 only.  
   --Below code commented by ravi on 12/4/15
   -- Update below no longer needed here this is logic done in EI using new procedure ALP_qryAlpEI_TransTax_Insert_sp
   --UPDATE tblArTransTax SET TaxAmt  =@pSalesTax ,TaxAmtFgn  =@pSalesTaxFgn WHERE TransId =@pTransId and Level =1  
END