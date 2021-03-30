
--NEW VIEW 022610.  See about using this to filter out any projects 
--			from ONHOLD report that might not have any commission left ON HOLD
--			(i.e. all jobs with comm have been paid, or are listed on the Eligible report)
CREATE VIEW [dbo].[ALP_rptJmComm_RepProjects_ONHOLD]
--created 022610 mah
AS
SELECT CS.SalesRep,dbo.ALP_tmpJmComm_EligibleJobs.ProjectId, 
		SUM(ALP_tmpJmComm_EligibleJobs.CommAmt) AS TotCommAmt
FROM dbo.ALP_tmpJmComm_EligibleJobs 
	INNER JOIN dbo.ALP_tblJmSvcTktCommSplit CS 
		ON	dbo.ALP_tmpJmComm_EligibleJobs.TicketId = CS.TicketID
GROUP BY CS.SalesRep,dbo.ALP_tmpJmComm_EligibleJobs.ProjectId
having SUM(ALP_tmpJmComm_EligibleJobs.CommAmt) > 0
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects_ONHOLD] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects_ONHOLD] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects_ONHOLD] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects_ONHOLD] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects_ONHOLD] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects_ONHOLD] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects_ONHOLD] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects_ONHOLD] TO PUBLIC
    AS [dbo];

