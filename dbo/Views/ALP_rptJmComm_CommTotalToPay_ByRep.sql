
--
CREATE VIEW [dbo].[ALP_rptJmComm_CommTotalToPay_ByRep]
AS
SELECT   
	CS.SalesRep,
	EJ.ProjectId, 
    	--TotalCommissionAmt = SUM(EJ.CommAmt),
	SaleRepTotal = SUM(CS.CommAmt),
	SaleRepPaid = SUM(
		CASE WHEN (EJ.CommToBePaidFlag = 1) AND isdate(EJ.CommPaidDate) <> 0 THEN CS.CommAmt 
			ELSE 0 END),
	SaleRepToPay = SUM(CASE	WHEN (EJ.CommToBePaidFlag = 1) AND (isdate(EJ.CommPaidDate) = 0) THEN CS.CommAmt 
			ELSE 0 END),
	SaleRepOnHoldProject_Paid = SUM(CASE WHEN (EJ.CommToBePaidFlag <> 1) AND isdate(EJ.CommPaidDate) <> 0 
				THEN CS.CommAmt ELSE 0 END),
	SaleRepOnHoldProject_NotPaid = SUM(CASE	WHEN (EJ.CommToBePaidFlag <> 1) AND (isdate(EJ.CommPaidDate) = 0) 
				THEN CS.CommAmt ELSE 0 END)
FROM dbo.ALP_tmpJmComm_EligibleJobs EJ INNER JOIN
    dbo.ALP_rptJmComm_EligibleJobs_CommSplitSub CS ON 
    EJ.TicketID = CS.TicketID
--WHERE EJ.CommToBePaidFlag = 1
GROUP BY CS.SalesRep,EJ.ProjectID
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_CommTotalToPay_ByRep] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_CommTotalToPay_ByRep] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_CommTotalToPay_ByRep] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_CommTotalToPay_ByRep] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_CommTotalToPay_ByRep] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_CommTotalToPay_ByRep] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_CommTotalToPay_ByRep] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_CommTotalToPay_ByRep] TO PUBLIC
    AS [dbo];

