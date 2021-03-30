
--
CREATE VIEW [dbo].[ALP_rptJmComm_EligibleJobs_CommSplitSub]
AS
SELECT   dbo.ALP_tmpJmComm_EligibleJobs.ProjectId,
     dbo.ALP_tblJmSvcTktCommSplit.TicketId, 
    dbo.ALP_tblJmSvcTktCommSplit.CommSplitID, 
    dbo.ALP_tblJmSvcTktCommSplit.SalesRep, 
    dbo.ALP_tblJmSvcTktCommSplit.CommSplitPct, 
    dbo.ALP_tblJmSvcTktCommSplit.CommAmt, 
    dbo.ALP_tblJmSvcTktCommSplit.Comments
FROM dbo.ALP_tblJmSvcTktCommSplit INNER JOIN
    dbo.ALP_tmpJmComm_EligibleJobs ON 
    dbo.ALP_tmpJmComm_EligibleJobs.TicketId = dbo.ALP_tblJmSvcTktCommSplit.TicketID

--
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplitSub] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplitSub] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplitSub] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplitSub] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplitSub] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplitSub] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplitSub] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplitSub] TO PUBLIC
    AS [dbo];

