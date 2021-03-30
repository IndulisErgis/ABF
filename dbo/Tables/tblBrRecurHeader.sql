CREATE TABLE [dbo].[tblBrRecurHeader] (
    [TransID]    [dbo].[pTransID]     NOT NULL,
    [BankID]     [dbo].[pBankID]      NULL,
    [TransType]  SMALLINT             CONSTRAINT [DF__tblBrRecu__Trans__49BDCDC9] DEFAULT (4) NULL,
    [SourceID]   VARCHAR (10)         NULL,
    [Descr]      [dbo].[pDescription] NULL,
    [TransDate]  DATETIME             NULL,
    [GLPeriod]   SMALLINT             CONSTRAINT [DF__tblBrRecu__GLPer__4AB1F202] DEFAULT (1) NULL,
    [FiscalYear] SMALLINT             CONSTRAINT [DF__tblBrRecu__Fisca__4BA6163B] DEFAULT (0) NULL,
    [Reference]  VARCHAR (15)         NULL,
    [Amount]     [dbo].[pDec]         CONSTRAINT [DF__tblBrRecu__Amoun__4C9A3A74] DEFAULT (0) NULL,
    [AmountFgn]  [dbo].[pDec]         CONSTRAINT [DF__tblBrRecu__Amoun__4D8E5EAD] DEFAULT (0) NULL,
    [CurrencyId] [dbo].[pCurrency]    NULL,
    [ExchRate]   [dbo].[pDec]         CONSTRAINT [DF__tblBrRecu__ExchR__4E8282E6] DEFAULT (1) NULL,
    [ts]         ROWVERSION           NULL,
    [CF]         XML                  NULL,
    CONSTRAINT [PK__tblBrRecurHeader__64CCF2AE] PRIMARY KEY CLUSTERED ([TransID] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrRecurHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrRecurHeader';

