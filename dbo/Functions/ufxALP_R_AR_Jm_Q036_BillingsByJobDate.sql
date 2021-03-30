
/* from qryJm-Q036-BillingsByJobDate  - 12/15/14 - ER */
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q036_BillingsByJobDate] 
(	
	@EndDate dateTime
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
HHV.AlpJobNum,
CASE WHEN HHV.InvcDate <= @EndDate THEN ([TaxSubtotal]+[NonTaxSubtotal])*[transtype] ELSE 0 END AS BilledAmt,
HHV.InvcDate AS InvoiceDate

FROM ALP_tblArHistHeader_view AS HHV

GROUP BY 
HHV.AlpJobNum, 
CASE WHEN HHV.InvcDate <= @EndDate THEN ([TaxSubtotal]+[NonTaxSubtotal])*[transtype] ELSE 0 END,
HHV.InvcDate

HAVING HHV.AlpJobNum Is Not NULL

)