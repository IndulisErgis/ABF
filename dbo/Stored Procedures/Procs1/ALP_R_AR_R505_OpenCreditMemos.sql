
CREATE PROCEDURE [dbo].[ALP_R_AR_R505_OpenCreditMemos]
AS
BEGIN
SET NOCOUNT ON

SELECT 
OI.CustId,
CU.CustName +
	CASE 
	WHEN CU.AlpFirstName IS null THEN ''
	WHEN CU.AlpFirstName =  '' THEN ''
	ELSE ', ' + CU.AlpFirstName END
	AS Cust, 
-- OI.RecType, 
OI.TransDate,
OI.InvcNum, 
isnull(OI.PmtMethodId,'') AS Method, 
Sum(OI.Amt) AS Balance

FROM ALP_tblArOpenInvoice_view AS OI 
INNER JOIN ALP_tblArCust_view AS CU 
ON OI.CustId = CU.CustId

GROUP BY 
OI.CustId, 
CU.CustName +
	CASE 
		WHEN CU.AlpFirstName IS null THEN ''
		WHEN CU.AlpFirstName = '' THEN ''
		ELSE (', ' + CU.AlpFirstName) END,
OI.RecType, 
OI.Amt,
OI.InvcNum, 
OI.TransDate, 
OI.PmtMethodId, 
OI.Status

HAVING OI.RecType=-1 AND Sum(OI.Amt)<>0 AND OI.Status=0

ORDER BY OI.CustId

END