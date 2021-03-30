CREATE VIEW [dbo].[ALP_rptJmComm_EligibleJobs_CommSplit]
AS
SELECT   dbo.ALP_tmpJmComm_EligibleJobs.TicketId, 
    dbo.ALP_tmpJmComm_EligibleJobs.ProjectId, 
    dbo.ALP_tmpJmComm_EligibleJobs.CustId, 
    dbo.ALP_tmpJmComm_EligibleJobs.SiteId, 
    SiteName = CASE WHEN S.AlpFirstName is null THEN S.SiteName
		WHEN S.AlpFirstName = '' THEN S.SiteName
		ELSE S.SiteName + ', ' + S.AlpFirstName  END ,
    dbo.ALP_tmpJmComm_EligibleJobs.InvcNum, 
    TotalCommissionAmt = dbo.ALP_tmpJmComm_EligibleJobs.CommAmt,
     dbo.ALP_tmpJmComm_EligibleJobs.CommPaidDate, 
    dbo.ALP_tmpJmComm_EligibleJobs.[Status], 
    dbo.ALP_tmpJmComm_EligibleJobs.CommPayNowYn,
    CASE WHEN dbo.ALP_tmpJmComm_EligibleJobs.CommPayNowYn = 1 
		THEN 'F'
		ELSE ''
		END as ForcePay, 
    dbo.ALP_tblJmWorkCode.WorkCode, 
    CsFlagYn = CASE WHEN dbo.ALP_tmpJmComm_EligibleJobs.CsConnectYn = 1 THEN
     'YES' ELSE '' END, 
    dbo.ALP_tmpJmComm_EligibleJobs.CsConnectYn, 
    dbo.ALP_tmpJmComm_EligibleJobs.TODate, 
    dbo.ALP_tmpJmComm_EligibleJobs.JobPrice, 
    dbo.ALP_tmpJmComm_EligibleJobs.InvcBilledAmt, 
    dbo.ALP_tmpJmComm_EligibleJobs.InvcDate, 
    dbo.ALP_tmpJmComm_EligibleJobs.InvcBalance, 
    dbo.ALP_tmpJmComm_EligibleJobs.InvcStatus, 
    dbo.ALP_tmpJmComm_EligibleJobs.RMRAdded, 
    RecurSvcPaidYn = CASE WHEN dbo.ALP_tmpJmComm_EligibleJobs.RecurSvcPaidYn = 1
     THEN 'YES' WHEN dbo.ALP_tmpJmComm_EligibleJobs.RecurSvcPaidYn
     <> 1 AND 
    dbo.ALP_tmpJmComm_EligibleJobs.CsConnectYn = 1 THEN 'NO' ELSE
     ' ' END, 
    dbo.ALP_tmpJmComm_EligibleJobs.CommToBePaidFlag AS PayYn, 
    CASE WHEN dbo.ALP_tmpJmComm_EligibleJobs.CommToBePaidFlag
     = 1 THEN 'YES' ELSE '' END AS CommToBePaidFlag
FROM dbo.ALP_tmpJmComm_EligibleJobs
	INNER JOIN  dbo.ALP_tblArAlpSite S ON dbo.ALP_tmpJmComm_EligibleJobs.SiteID = S.SiteID
   	INNER JOIN  dbo.ALP_tblJmWorkCode ON  dbo.ALP_tmpJmComm_EligibleJobs.WorkCodeID = dbo.ALP_tblJmWorkCode.WorkCodeId
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplit] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplit] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplit] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplit] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplit] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplit] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplit] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleJobs_CommSplit] TO PUBLIC
    AS [dbo];

