CREATE TABLE [dbo].[ALP_tmpJmComm_RunDate] (
    [ID]                 INT      CONSTRAINT [DF_tmpJmComm_RunDate_ID] DEFAULT (1) NOT NULL,
    [CommissionsRunDate] DATETIME CONSTRAINT [DF_tmpJmComm_RunDate_CommissionsRunDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_tmpJmComm_RunDate] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tmpJmComm_RunDate] TO [JMCommissions]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tmpJmComm_RunDate] TO [JMCommissions]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tmpJmComm_RunDate] TO [JMCommissions]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tmpJmComm_RunDate] TO [JMCommissions]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tmpJmComm_RunDate] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tmpJmComm_RunDate] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tmpJmComm_RunDate] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tmpJmComm_RunDate] TO PUBLIC
    AS [dbo];

