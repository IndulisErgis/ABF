
--
CREATE VIEW [dbo].[ALP_stpJmComm_EligibleJobs_CommSplit]
AS
SELECT    dbo.ALP_tmpJmComm_EligibleJobs.TicketId, 
    dbo.ALP_tmpJmComm_EligibleJobs.ProjectId, 
    dbo.ALP_tmpJmComm_EligibleJobs.CustId, 
    dbo.ALP_tmpJmComm_EligibleJobs.SiteId, 
    dbo.ALP_tmpJmComm_EligibleJobs.InvcNum, 
    TotalCommissionAmt = dbo.ALP_tmpJmComm_EligibleJobs.CommAmt,
     dbo.ALP_tmpJmComm_EligibleJobs.CommPaidDate, 
    dbo.ALP_tmpJmComm_EligibleJobs.Status, 
    dbo.ALP_tmpJmComm_EligibleJobs.CommPayNowYn, 
    dbo.ALP_tmpJmComm_EligibleJobs.InvcStatus, 
    dbo.ALP_tblJmWorkCode.WorkCode, 
    dbo.ALP_tmpJmComm_EligibleJobs.CsConnectYn, 
    dbo.ALP_tmpJmComm_EligibleJobs.TODate, 
    dbo.ALP_tmpJmComm_EligibleJobs.JobPrice, 
    dbo.ALP_tmpJmComm_EligibleJobs.InvcBilledAmt, 
    dbo.ALP_tmpJmComm_EligibleJobs.InvcPaidDate, 
    dbo.ALP_tmpJmComm_EligibleJobs.RecurSvcPaidYn, 
    dbo.ALP_tmpJmComm_EligibleJobs.CommToBePaidFlag, 
    dbo.ALP_tblJmSvcTktCommSplit.SalesRep, 
    dbo.ALP_tblJmSvcTktCommSplit.CommSplitPct, 
    dbo.ALP_tblJmSvcTktCommSplit.CommAmt, 
    dbo.ALP_tblJmSvcTktCommSplit.Comments
FROM dbo.ALP_tmpJmComm_EligibleJobs INNER JOIN
    dbo.ALP_tblJmWorkCode ON 
    dbo.ALP_tmpJmComm_EligibleJobs.WorkCodeID = dbo.ALP_tblJmWorkCode.WorkCodeId
     LEFT OUTER JOIN
    dbo.ALP_tblJmSvcTktCommSplit ON 
    dbo.ALP_tmpJmComm_EligibleJobs.TicketId = dbo.ALP_tblJmSvcTktCommSplit.TicketID

--
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs_CommSplit] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs_CommSplit] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs_CommSplit] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs_CommSplit] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs_CommSplit] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs_CommSplit] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs_CommSplit] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_stpJmComm_EligibleJobs_CommSplit] TO PUBLIC
    AS [dbo];

