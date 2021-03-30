
/* from qryJm-Q036B-BillingsByJobMaxDate  - 12/15/14 - ER */
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q036B_BillingsByJobMaxDate] 
(	
	@EndDate dateTime
)
RETURNS TABLE 
AS
RETURN 
(
SELECT 
qry36.AlpJobNum, 
Sum(qry36.BilledAmt) AS Billed, 
Max(qry36.InvoiceDate) AS MaxInvcDate

FROM ufxALP_R_AR_Jm_Q036_BillingsByJobDate(@EndDate) AS qry36

GROUP BY qry36.AlpJobNum

)