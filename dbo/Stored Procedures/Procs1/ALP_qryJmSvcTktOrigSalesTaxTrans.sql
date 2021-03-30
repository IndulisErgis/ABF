
CREATE PROCEDURE [dbo].[ALP_qryJmSvcTktOrigSalesTaxTrans]
@ID int
--modified by mah 3/1/14 - to get existing sales tax for the transaction, summing taxes from Transheader rather than taxes table
As
SET NOCOUNT ON
--SELECT ALP_tblArTransHeader_view.AlpJobNum, Sum(tblArTransTax.TaxAmt) AS OrigSalesTax
--FROM ALP_tblArTransHeader_view INNER JOIN tblArTransTax ON ALP_tblArTransHeader_view.TransId = tblArTransTax.TransId
SELECT ALP_tblArTransHeader_view.AlpJobNum, Sum(ALP_tblArTransHeader_view.SalesTax) AS OrigSalesTax
FROM ALP_tblArTransHeader_view	
WHERE ALP_tblArTransHeader_view.AlpFromJobYN =1
GROUP BY ALP_tblArTransHeader_view.AlpJobNum
HAVING ALP_tblArTransHeader_view.AlpJobNum = @ID