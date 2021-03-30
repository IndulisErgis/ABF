CREATE Procedure [dbo].[ALP_rptJmComm_EligibleProjectsToPay_sp]
AS
SET NOCOUNT ON
SELECT * FROM dbo.ALP_rptJmComm_EligibleJobs_CommSplit
WHERE PayYn = 1
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsToPay_sp] TO [JMCommissions]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsToPay_sp] TO PUBLIC
    AS [dbo];

