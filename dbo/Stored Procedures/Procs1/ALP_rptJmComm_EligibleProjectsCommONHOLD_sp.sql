CREATE Procedure [dbo].[ALP_rptJmComm_EligibleProjectsCommONHOLD_sp]
AS
SET NOCOUNT ON
SELECT * FROM dbo.ALP_rptJmComm_EligibleJobs_CommSplit
--mah 03/5/10 : show all jobs in project - even if eligible this period 
--WHERE PayYn <> 1
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsCommONHOLD_sp] TO [JMCommissions]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsCommONHOLD_sp] TO PUBLIC
    AS [dbo];

