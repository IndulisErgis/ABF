CREATE TABLE [dbo].[tblGlTrans] (
    [TransId]         UNIQUEIDENTIFIER  NOT NULL,
    [EntryDate]       DATETIME          NOT NULL,
    [TransDate]       DATETIME          NOT NULL,
    [Descr]           VARCHAR (30)      NULL,
    [SourceCode]      VARCHAR (2)       NULL,
    [Reference]       VARCHAR (15)      NULL,
    [AcctId]          [dbo].[pGlAcct]   NULL,
    [CurrencyId]      [dbo].[pCurrency] NOT NULL,
    [ExchRate]        [dbo].[pDec]      CONSTRAINT [DF_tblGlTrans_ExchRate] DEFAULT ((1)) NOT NULL,
    [DebitAmountFgn]  [dbo].[pCurrDec]  CONSTRAINT [DF_tblGlTrans_DebitAmtFgn] DEFAULT ((0)) NOT NULL,
    [CreditAmountFgn] [dbo].[pCurrDec]  CONSTRAINT [DF_tblGlTrans_CreditAmtFgn] DEFAULT ((0)) NOT NULL,
    [FiscalYear]      SMALLINT          CONSTRAINT [DF_tblGlTrans_FiscalYear] DEFAULT ((0)) NOT NULL,
    [FiscalPeriod]    SMALLINT          CONSTRAINT [DF_tblGlTrans_FiscalPeriod] DEFAULT ((0)) NOT NULL,
    [AllocateYn]      BIT               CONSTRAINT [DF_tblGlTrans_AllocateYn] DEFAULT ((0)) NOT NULL,
    [ChkRecon]        BIT               CONSTRAINT [DF_tblGlTrans_ChkRecon] DEFAULT ((0)) NOT NULL,
    [CashFlow]        BIT               CONSTRAINT [DF_tblGlTrans_CashFlow] DEFAULT ((0)) NOT NULL,
    [UserId]          [dbo].[pUserID]   NOT NULL,
    [AllocParentId]   UNIQUEIDENTIFIER  NULL,
    [LineSequence]    INT               CONSTRAINT [DF_tblGlTrans_LineSequence] DEFAULT ((0)) NOT NULL,
    [CF]              XML               NULL,
    [ts]              ROWVERSION        NULL,
    [BatchId]         [dbo].[pBatchID]  CONSTRAINT [DF_tblGlTrans_BatchId] DEFAULT ('######') NOT NULL,
    CONSTRAINT [PK_tblGlTrans] PRIMARY KEY CLUSTERED ([TransId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblGlTrans_FiscalYear]
    ON [dbo].[tblGlTrans]([FiscalYear] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblGlTrans_BatchId]
    ON [dbo].[tblGlTrans]([BatchId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblGlTrans_UserId]
    ON [dbo].[tblGlTrans]([UserId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlTrans';

