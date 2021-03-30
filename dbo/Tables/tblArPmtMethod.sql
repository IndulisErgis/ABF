CREATE TABLE [dbo].[tblArPmtMethod] (
    [PmtMethodID]       VARCHAR (10)         NOT NULL,
    [Desc]              VARCHAR (30)         NULL,
    [PmtType]           SMALLINT             CONSTRAINT [DF__tblArPmtM__PmtTy__474B7572] DEFAULT (1) NULL,
    [GLAcctDebit]       [dbo].[pGlAcct]      NULL,
    [BankId]            [dbo].[pBankID]      NULL,
    [CustId]            [dbo].[pCustID]      NULL,
    [ts]                ROWVERSION           NULL,
    [OpenDrawer]        BIT                  CONSTRAINT [DF__tblArPmtM__OpenD__47A473E0] DEFAULT ((0)) NOT NULL,
    [CF]                XML                  NULL,
    [CurrencyID]        [dbo].[pCurrency]    NULL,
    [Status]            TINYINT              CONSTRAINT [DF_tblArPmtMethod_Status] DEFAULT ((0)) NOT NULL,
    [MobileEnabled]     BIT                  CONSTRAINT [DF_tblArPmtMethod_MobileEnabled] DEFAULT ((0)) NOT NULL,
    [MobileDescription] [dbo].[pDescription] NULL,
    [MobileImage]       VARBINARY (MAX)      NULL,
    CONSTRAINT [PK__tblArPmtMethod__3335971A] PRIMARY KEY CLUSTERED ([PmtMethodID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlPmtType]
    ON [dbo].[tblArPmtMethod]([PmtType] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlCustId]
    ON [dbo].[tblArPmtMethod]([CustId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlBankId]
    ON [dbo].[tblArPmtMethod]([BankId] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArPmtMethod';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArPmtMethod';

