CREATE FUNCTION [dbo].[ufxALP_R_AR_R587_Q002_OpenItems_Q001]()
RETURNS TABLE 
AS
RETURN 
(
/* qryAr-Q002-OpenItems-Q001 */
SELECT 
OI_All.CustId, 
OI_All.InvcNum, 
OI_All.FirstOfTransDate, 
OI_All.InvcAmt, 
OI_All.CreditAmt

FROM ufxALP_R_AR_R587_Q001_OpenItemsAll() as OI_All

WHERE InvcAmt - creditamt <>0

GROUP BY 
OI_All.CustId, 
OI_All.InvcNum, 
OI_All.FirstOfTransDate, 
OI_All.InvcAmt, 
OI_All.CreditAmt
)