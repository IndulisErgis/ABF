
CREATE Procedure [dbo].[ALP_rptJmComm_EligibleProjectsONHOLD_ByRep_sp]
AS
SET NOCOUNT ON
SELECT P.SalesRep, CS.* FROM dbo.ALP_rptJmComm_EligibleJobs_CommSplit CS
INNER JOIN dbo.ALP_rptJmComm_RepProjects P
ON CS.ProjectID = P.ProjectID
--mah 03/5/10 : show all jobs in project - even if eligible this period
--WHERE PayYn <> 1
ORDER BY P.SalesRep, CS.ProjectID, CS.TicketID
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsONHOLD_ByRep_sp] TO [JMCommissions]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsONHOLD_ByRep_sp] TO PUBLIC
    AS [dbo];

