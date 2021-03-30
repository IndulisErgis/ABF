

CREATE VIEW [dbo].[ALP_rptJmComm_RepProjects]
AS
SELECT DISTINCT CS.SalesRep,dbo.ALP_tmpJmComm_EligibleJobs.ProjectId
FROM dbo.ALP_tmpJmComm_EligibleJobs 
	INNER JOIN dbo.ALP_tblJmSvcTktCommSplit CS ON
		dbo.ALP_tmpJmComm_EligibleJobs.TicketId = CS.TicketID
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_RepProjects] TO PUBLIC
    AS [dbo];

