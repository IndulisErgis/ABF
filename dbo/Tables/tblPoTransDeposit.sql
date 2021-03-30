CREATE TABLE [dbo].[tblPoTransDeposit] (
    [ID]                BIGINT            NOT NULL,
    [TransID]           [dbo].[pTransID]  NOT NULL,
    [DepositDate]       DATETIME          NOT NULL,
    [Amount]            [dbo].[pDecimal]  NOT NULL,
    [AmountBase]        [dbo].[pDecimal]  NOT NULL,
    [AmountApplied]     [dbo].[pDecimal]  CONSTRAINT [DF_tblPoTransDeposit_AmountApplied] DEFAULT ((0)) NOT NULL,
    [AmountAppliedBase] [dbo].[pDecimal]  CONSTRAINT [DF_tblPoTransDeposit_AmountAppliedBase] DEFAULT ((0)) NOT NULL,
    [ExchRate]          [dbo].[pDecimal]  CONSTRAINT [DF_tblPoTransDeposit_ExchRate] DEFAULT ((1)) NOT NULL,
    [FiscalYear]        SMALLINT          NOT NULL,
    [FiscalPeriod]      SMALLINT          NOT NULL,
    [EntryDate]         DATETIME          NOT NULL,
    [InvoiceCounter]    INT               NULL,
    [Notes]             NVARCHAR (MAX)    NULL,
    [BankID]            [dbo].[pBankID]   NULL,
    [PaymentNumber]     [dbo].[pCheckNum] NULL,
    [PostRun]           [dbo].[pPostRun]  NULL,
    [DepositGLAcct]     [dbo].[pGlAcct]   NULL,
    [CF]                XML               NULL,
    [ts]                ROWVERSION        NULL,
    CONSTRAINT [PK_tblPoTransDeposit] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPoTransDeposit_InvoiceCounter]
    ON [dbo].[tblPoTransDeposit]([InvoiceCounter] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPoTransDeposit_TransId]
    ON [dbo].[tblPoTransDeposit]([TransID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransDeposit';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransDeposit';

