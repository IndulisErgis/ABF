
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q005B_JobBillAmt] 
(	
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
--removed HH.InvcNam & HH.InvcNum from function unused and grouping causing problems - 6/2/16 - ER & MAH
HH.AlpJobNum, 
Sum((HH.[TaxSubtotal]+HH.[NonTaxSubtotal])*HH.[TransType]) AS Billed, 
Sum((HH.[TaxSubtotal]+HH.[NonTaxSubtotal]+HH.[SalesTax]+HH.[Freight]+HH.[Misc])*HH.[TransType]) AS BilledTotal

FROM ALP_tblArHistHeader_view AS HH

GROUP BY HH.AlpJobNum
)