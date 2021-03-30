

CREATE PROCEDURE [dbo].[ALP_R_AR_R520_SalesTaxByLoc] 
(
@StartDate datetime,
@EndDate datetime
)
AS
BEGIN
	SET NOCOUNT ON;
SELECT 
HH.InvcDate, 
HT.TaxLocID, 
HT.TaxAmt*HH.TransType AS Tax, 
HT.Taxable*HH.TransType AS TaxableAmt, 
HT.NonTaxable*HH.TransType AS NonTaxableAmt

FROM ALP_tblArHistHeader_view AS HH
	INNER JOIN tblArHistTax AS HT
		ON HH.TransId = HT.TransId 
	AND 
		HH.PostRun = HT.PostRun

WHERE 
HH.InvcDate 
Between @StartDate And @EndDate

END