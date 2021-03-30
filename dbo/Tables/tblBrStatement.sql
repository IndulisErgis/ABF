CREATE TABLE [dbo].[tblBrStatement] (
    [ID]            BIGINT               NOT NULL,
    [BankID]        [dbo].[pBankID]      NOT NULL,
    [StatementDate] DATETIME             NOT NULL,
    [Status]        TINYINT              CONSTRAINT [DF_tblBrStatement_Status] DEFAULT ((0)) NOT NULL,
    [Description]   [dbo].[pDescription] NULL,
    [Reference]     [dbo].[pDescription] NULL,
    [BeginDate]     DATETIME             NOT NULL,
    [EndDate]       DATETIME             NOT NULL,
    [BeginBalance]  [dbo].[pDecimal]     NOT NULL,
    [EndBalance]    [dbo].[pDecimal]     NOT NULL,
    [TransCount]    INT                  NULL,
    [CF]            XML                  NULL,
    [ts]            ROWVERSION           NULL,
    [FiscalPeriod]  SMALLINT             NOT NULL,
    [FiscalYear]    SMALLINT             NOT NULL,
    CONSTRAINT [PK_tblBrStatement] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblBrStatement_BankIDStatus]
    ON [dbo].[tblBrStatement]([BankID] ASC, [Status] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblBrStatement_BankIDStatementDate]
    ON [dbo].[tblBrStatement]([BankID] ASC, [StatementDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrStatement';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrStatement';

