CREATE TABLE [dbo].[tblGlAcctHdr] (
    [AcctId]       [dbo].[pGlAcct]   NOT NULL,
    [Desc]         VARCHAR (30)      NULL,
    [AcctTypeId]   SMALLINT          NULL,
    [BalType]      SMALLINT          CONSTRAINT [DF__tblGlAcct__BalTy__62897B93] DEFAULT (1) NULL,
    [ClearToAcct]  [dbo].[pGlAcct]   NULL,
    [ClearToStep]  TINYINT           CONSTRAINT [DF__tblGlAcct__Clear__637D9FCC] DEFAULT (0) NULL,
    [ConsolToAcct] [dbo].[pGlAcct]   NULL,
    [ConsolToStep] TINYINT           CONSTRAINT [DF__tblGlAcct__Conso__6471C405] DEFAULT (0) NULL,
    [ts]           ROWVERSION        NULL,
    [Status]       TINYINT           DEFAULT ((0)) NOT NULL,
    [CurrencyID]   [dbo].[pCurrency] NULL,
    [CF]           XML               NULL,
    CONSTRAINT [PK__tblGlAcctHdr__7132C993] PRIMARY KEY CLUSTERED ([AcctId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlStatus]
    ON [dbo].[tblGlAcctHdr]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlAcctTypeId]
    ON [dbo].[tblGlAcctHdr]([AcctTypeId] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctHdr';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctHdr';

