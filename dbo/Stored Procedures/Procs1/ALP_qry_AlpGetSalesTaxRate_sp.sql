CREATE PROCEDURE [dbo].[ALP_qry_AlpGetSalesTaxRate_sp]  
 @TaxLocID VARCHAR(10) = NULL,  
 @TaxClassCode TINYINT = NULL  
AS  
 /*  
  Created by JM for EFI#1893 on 06/07/2010  
  Modified by ravi on 11/24/2015, Reason: TaxableYN take out from the filter condition
  due to Traverse is no longer using it, 
  
 */  
IF EXISTS (SELECT * FROM tblSmTaxLocDetail WHERE TaxLocId = @TaxLocId AND TaxClassCode = @TaxClassCode)
 --AND TaxableYN = 1)  
 SELECT SalesTaxPct FROM tblSmTaxLocDetail WHERE TaxLocId = @TaxLocId AND
  TaxClassCode = @TaxClassCode 
  --AND TaxableYN = 1  
ELSE  
 SELECT 0 AS SalesTaxPct