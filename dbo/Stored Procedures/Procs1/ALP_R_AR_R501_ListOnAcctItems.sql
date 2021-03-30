CREATE PROCEDURE [dbo].[ALP_R_AR_R501_ListOnAcctItems] 
AS

BEGIN
	SET NOCOUNT ON;

SELECT  
OI.CustId,
AC.CustName,
AC.AlpFirstName, 
OI.TransDate,
OI.InvcNum, 
OI.PmtMethodId,
Sum(OI.Amt) AS Balance 

FROM ALP_tblArOpenInvoice_view AS OI
	INNER JOIN ALP_tblArCust_view AS AC
		ON OI.CustId = AC.AlpCustId

GROUP BY OI.CustId, 
AC.CustName,
AC.AlpFirstName,
OI.TransDate, 
OI.InvcNum, 
OI.PmtMethodId, 
OI.Status

HAVING (OI.InvcNum Like 'ON ACC%') AND 
(Sum(OI.Amt)<>0 AND OI.Status = 0)

ORDER BY OI.CustId, OI.TransDate;

END