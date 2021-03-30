CREATE PROCEDURE [dbo].[ALP_R_AR_R506_DailyCashReceipts]
(
@GLPeriod int,
@FiscalYr int
)
AS
BEGIN
SET NOCOUNT ON;

SELECT 
HP.GLPeriod, 
HP.FiscalYear, 
PM.GLAcctDebit, 
HP.PmtDate, 
Sum(HP.PmtAmt) AS Amount

FROM tblArHistPmt AS HP
	INNER JOIN tblArPmtMethod AS PM 
		ON HP.PmtMethodId = PM.PmtMethodID
		
WHERE (HP.GLPeriod = @GLPeriod) 
		AND (HP.FiscalYear = @FiscalYr )


GROUP BY 
HP.GLPeriod, 
HP.FiscalYear, 
PM.GLAcctDebit, 
HP.PmtDate

END