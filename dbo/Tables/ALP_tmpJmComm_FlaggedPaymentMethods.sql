CREATE TABLE [dbo].[ALP_tmpJmComm_FlaggedPaymentMethods] (
    [PaymentMethodID] VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_tmpJmComm_FlaggedPaymentMethods] PRIMARY KEY CLUSTERED ([PaymentMethodID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tmpJmComm_FlaggedPaymentMethods] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tmpJmComm_FlaggedPaymentMethods] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tmpJmComm_FlaggedPaymentMethods] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tmpJmComm_FlaggedPaymentMethods] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tmpJmComm_FlaggedPaymentMethods] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tmpJmComm_FlaggedPaymentMethods] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tmpJmComm_FlaggedPaymentMethods] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tmpJmComm_FlaggedPaymentMethods] TO PUBLIC
    AS [dbo];

