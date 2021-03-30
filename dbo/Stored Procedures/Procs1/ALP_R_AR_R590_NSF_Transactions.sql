

CREATE PROCEDURE [dbo].[ALP_R_AR_R590_NSF_Transactions] 
(
@StartDate datetime,
@EndDate datetime
)
AS
BEGIN
SET NOCOUNT ON

SELECT 
AC.CustId, 
AC.CustName, 
HP.PmtDate, 
HP.PmtMethodId, 
HP.InvcNum, 
HP.PmtAmt, 
HP.CheckNum, 
HP.BankID, 
HP.DepNum

FROM tblArHistPmt AS HP
		INNER JOIN tblArPmtMethod 
	ON HP.PmtMethodId = tblArPmtMethod.PmtMethodID 
		INNER JOIN ALP_tblArCust_view AS AC
	ON HP.CustId = AC.CustId

WHERE HP.PmtDate 
Between @StartDate And @EndDate 
AND HP.PmtMethodId='NSF'

END