CREATE TABLE [dbo].[tblPoHistDeposit] (
    [ID]                BIGINT            NOT NULL,
    [TransPostRun]      [dbo].[pPostRun]  NOT NULL,
    [TransId]           [dbo].[pTransID]  NOT NULL,
    [DepositDate]       DATETIME          NOT NULL,
    [Amount]            [dbo].[pDecimal]  NOT NULL,
    [AmountBase]        [dbo].[pDecimal]  NOT NULL,
    [AmountApplied]     [dbo].[pDecimal]  NOT NULL,
    [AmountAppliedBase] [dbo].[pDecimal]  NOT NULL,
    [ExchRate]          [dbo].[pDecimal]  NOT NULL,
    [FiscalYear]        SMALLINT          NOT NULL,
    [FiscalPeriod]      SMALLINT          NOT NULL,
    [EntryDate]         DATETIME          NOT NULL,
    [InvoiceCounter]    INT               NULL,
    [Notes]             NVARCHAR (MAX)    NULL,
    [BankID]            [dbo].[pBankID]   NULL,
    [PaymentNumber]     [dbo].[pCheckNum] NULL,
    [PostRun]           [dbo].[pPostRun]  NOT NULL,
    [DepositGLAcct]     [dbo].[pGlAcct]   NOT NULL,
    [CF]                XML               NULL,
    CONSTRAINT [PK_tblPoHistDeposit] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPoHistDeposit_TransPostRunTransId]
    ON [dbo].[tblPoHistDeposit]([TransPostRun] ASC, [TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistDeposit';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistDeposit';

