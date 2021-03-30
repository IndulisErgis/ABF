CREATE FUNCTION [dbo].[ufxALP_R_AR_R587_Q001_OpenItemsAll] ()
RETURNS TABLE 
AS
RETURN 
(
SELECT 
OI.CustId, 
AC.AlpDealerYn, 
OI.InvcNum, 
MIN(OI.TransDate) AS FirstOfTransDate, 
Sum(CASE WHEN RecType=1 THEN Amt ELSE 0 END) AS InvcAmt, 
Sum(CASE WHEN RecType<1 THEN Amt ELSE 0 END) AS CreditAmt

FROM ALP_tblArOpenInvoice_view AS OI
	INNER JOIN ALP_tblArCust_view AS AC 
	ON OI.CustId = AC.CustId

GROUP BY 
OI.CustId, 
AC.AlpDealerYn, 
OI.InvcNum
)