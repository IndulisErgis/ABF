
  
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktUpdateTransHeaderTax]    
@JobNum int, @ActualTax pDec, @OrigSalesTax pDec,    
--Added by NSK on 15 Apr 2014    
@TaxAdjTaxClass int=0,@OriginalTaxAmt float=0    
As    
SET NOCOUNT ON    
  
DECLARE @TransId pTransId    
--DECLARE @TaxClass int    
SET @TransId = NULL    
--SET @TaxClass = NULL    
    
--find transaction and taxclass data to be updated    
SET @TransID =  (SELECT TransId from tblArTransHeader     
    left outer join ALP_tblArTransHeader     
    on tblArTransHeader.TransId=ALP_tblArTransHeader.AlpTransId    
    WHERE ALP_tblArTransHeader.AlpFromJobYN = 1     
    AND ALP_tblArTransHeader.AlpJobNum = @JobNum)    
--commented out by MAH 12/07/15 - revised code added after   
--SET @TaxClass = (SELECT MAX(TaxClass) FROM tblArTransTax INNER JOIN ALP_tblArTransHeader    
--                ON tblArTransTax.TransID = ALP_tblArTransHeader.AlpTransId    
--                WHERE @TransId IS NOT NULL AND tblArTransTax.TransId = @TransId AND TaxAmt <> 0    
--                GROUP BY tblArTransTax.TransId)    
                 
--UPDATE tblArTransHeader     
--SET tblArTransHeader.TaxAmtAdj = (@ActualTax - tblArTransHeader.SalesTax),   
--  tblArTransHeader.TaxAdj = 1,  
--  tblArTransHeader.TaxClassAdj = @TaxClass,  
--     tblArTransHeader.TaxAmtAdjFgn = (@ActualTax - tblArTransHeader.SalesTaxFgn)    
--      WHERE tblArTransHeader.TransId = @TransId    
--end of 12/7/15 commenetd out section

--revised code:
   --MAH 12/7/15 - to correctly insert the Tax Adjustment amount 
   --		when tax is manually overrriden usinb the JM Ticket scree
   UPDATE tblArTransHeader 
	   SET --SalesTax =@ActualTax ,SalesTaxFgn =@ActualTax,	--need fgn value
	   TaxAmtAdj = CASE WHEN (@ActualTax - tblArTransHeader.SalesTax) <> 0 THEN @ActualTax - tblArTransHeader.SalesTax
			ELSE tblArTransHeader.TaxAmtAdj END, 
	   TaxAmtAdjFgn = CASE WHEN (@ActualTax - tblArTransHeader.SalesTax) <> 0 THEN @ActualTax - tblArTransHeader.SalesTaxFgn
			ELSE  tblArTransHeader.TaxAmtAdjFgn END,
	   TaxLocAdj = CASE WHEN (@ActualTax - tblArTransHeader.SalesTax) <> 0 THEN tblSmTaxGroup.LevelOne
			ELSE  tblArTransHeader.TaxLocAdj END, 
	   TaxClassAdj = CASE WHEN (@ActualTax - tblArTransHeader.SalesTax) <> 0 THEN 1 ELSE TaxClassAdj END
   FROM tblArTransHeader INNER JOIN tblSmTaxGroup ON tblArTransHeader.TaxGrpID = tblSmTaxGroup.TaxGrpID    
   WHERE tblArTransHeader.TransId =  @TransId