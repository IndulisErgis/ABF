CREATE VIEW [dbo].[ALP_rptJmComm_EligibleProjectsToPay_vw]
AS
SELECT * FROM dbo.ALP_rptJmComm_EligibleJobs_CommSplit
WHERE PayYn = 1
GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsToPay_vw] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsToPay_vw] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsToPay_vw] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsToPay_vw] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsToPay_vw] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsToPay_vw] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsToPay_vw] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_rptJmComm_EligibleProjectsToPay_vw] TO PUBLIC
    AS [dbo];

