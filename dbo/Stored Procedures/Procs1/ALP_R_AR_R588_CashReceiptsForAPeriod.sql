
CREATE PROCEDURE [dbo].[ALP_R_AR_R588_CashReceiptsForAPeriod]
(
@StartDate datetime,
@EndDate datetime
)	
AS
BEGIN
SET NOCOUNT ON

SELECT 
HP.CustId, 
HP.PmtDate, 
PM.[Desc], 
PM.PmtType, 
CASE WHEN PM.PmtType<3 THEN PmtAmt ELSE 0 END AS CashPmts, 
CASE WHEN PM.PmtType>2 THEN PmtAmt ELSE 0 END AS NonCashPmts

FROM tblArHistPmt AS HP
	INNER JOIN tblArPmtMethod AS PM 
		ON HP.PmtMethodId = PM.PmtMethodID

WHERE HP.PmtDate Between @StartDate And @EndDate



END