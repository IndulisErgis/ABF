CREATE TABLE [dbo].[ALP_tblCSOptions] (
    [ID]                        INT           IDENTITY (1, 1) NOT NULL,
    [CentralID]                 INT           NULL,
    [SignalDateAllowance]       SMALLINT      CONSTRAINT [DF_tblCSOptions_SignalDateAllowance] DEFAULT (0) NULL,
    [CancelDateAllowance]       SMALLINT      CONSTRAINT [DF_tblCSOptions_CancelDateAllowance] DEFAULT (0) NULL,
    [TestSignalAllowance]       SMALLINT      CONSTRAINT [DF_tblCSOptions_TestSignalAllowance] DEFAULT (75) NULL,
    [LastCSBSRunDate]           SMALLDATETIME NULL,
    [LastSignalDateAllowance]   INT           CONSTRAINT [DF_tblCSOptions_LastSignalDateAllowance] DEFAULT (0) NULL,
    [LastCancelDateAllowance]   INT           CONSTRAINT [DF_tblCSOptions_LastCancelDateAllowance] DEFAULT (0) NULL,
    [StartBillingAllowance]     SMALLINT      CONSTRAINT [DF_tblCSOptions_StartBillingAllowance] DEFAULT (0) NULL,
    [LastStartBillingAllowance] SMALLINT      NULL,
    [RPTDSchedType]             VARCHAR (20)  NULL,
    [RPTDSchedID]               INT           CONSTRAINT [DF_tblCSOptions_RPTDSchedID] DEFAULT (0) NULL,
    [RPTMSchedType]             VARCHAR (20)  NULL,
    [RPTMSchedID]               INT           CONSTRAINT [DF_tblCSOptions_RPTMSchedID] DEFAULT (0) NULL,
    [RPTWSchedType]             VARCHAR (20)  NULL,
    [RPTWSchedID]               INT           CONSTRAINT [DF_tblCSOptions_RPTWSchedID] DEFAULT (0) NULL,
    [LastCompareStartTrans]     VARCHAR (36)  NULL,
    [LastCompareEndTrans]       VARCHAR (36)  NULL,
    CONSTRAINT [PK_tblCSOptions] PRIMARY KEY NONCLUSTERED ([ID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblCSOptions] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblCSOptions] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblCSOptions] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblCSOptions] TO PUBLIC
    AS [dbo];

