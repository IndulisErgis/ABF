

/* from qryJm-Q036C-BillingsByJobMinDate  - 12/17/14 - ER */
CREATE FUNCTION [dbo].[ufxALP_R_AR_Jm_Q036C_BillingsByJobMinDate] 
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
Min(qry36.InvoiceDate) AS MinInvcDate

FROM ufxALP_R_AR_Jm_Q036_BillingsByJobDate(@EndDate) AS qry36

GROUP BY qry36.AlpJobNum

)