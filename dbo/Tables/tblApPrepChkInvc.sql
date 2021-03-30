CREATE TABLE [dbo].[tblApPrepChkInvc] (
    [VendorID]        [dbo].[pVendorID]   NOT NULL,
    [InvoiceNum]      [dbo].[pInvoiceNum] NOT NULL,
    [Counter]         INT                 CONSTRAINT [DF__tblApPrep__Count__37E93651] DEFAULT (0) NOT NULL,
    [Status]          TINYINT             CONSTRAINT [DF__tblApPrep__Statu__38DD5A8A] DEFAULT (0) NULL,
    [Ten99InvoiceYN]  BIT                 CONSTRAINT [DF__tblApPrep__Ten99__39D17EC3] DEFAULT (0) NULL,
    [DistCode]        [dbo].[pDistCode]   NULL,
    [InvoiceDate]     DATETIME            NULL,
    [DiscDueDate]     DATETIME            NULL,
    [NetDueDate]      DATETIME            NULL,
    [GrossAmtDue]     [dbo].[pDec]        CONSTRAINT [DF__tblApPrep__Gross__3AC5A2FC] DEFAULT (0) NULL,
    [DiscAmt]         [dbo].[pDec]        CONSTRAINT [DF__tblApPrep__DiscA__3BB9C735] DEFAULT (0) NULL,
    [GrossAmtDueFgn]  [dbo].[pDec]        CONSTRAINT [DF__tblApPrep__Gross__3CADEB6E] DEFAULT (0) NULL,
    [DiscAmtFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApPrep__DiscA__3DA20FA7] DEFAULT (0) NULL,
    [CheckNum]        [dbo].[pCheckNum]   NULL,
    [CheckDate]       DATETIME            NULL,
    [CurrencyId]      [dbo].[pCurrency]   NULL,
    [ExchRate]        [dbo].[pDec]        CONSTRAINT [DF__tblApPrepChkInvc_ExchRate] DEFAULT ((1)) NULL,
    [VendorHoldYN]    BIT                 CONSTRAINT [DF__tblApPrep__Vendo__3F8A5819] DEFAULT (0) NULL,
    [DiscLost]        [dbo].[pDec]        CONSTRAINT [DF__tblApPrep__DiscL__407E7C52] DEFAULT (0) NULL,
    [DiscTaken]       [dbo].[pDec]        CONSTRAINT [DF__tblApPrep__DiscT__4172A08B] DEFAULT (0) NULL,
    [DiscLostFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblApPrep__DiscL__4266C4C4] DEFAULT (0) NULL,
    [DiscTakenFgn]    [dbo].[pDec]        CONSTRAINT [DF__tblApPrep__DiscT__435AE8FD] DEFAULT (0) NULL,
    [Ten99FormCode]   VARCHAR (1)         NULL,
    [DropFlagYN]      BIT                 CONSTRAINT [DF__tblApPrep__DropF__444F0D36] DEFAULT (0) NULL,
    [CheckAmt]        [dbo].[pDec]        CONSTRAINT [DF__tblApPrep__Check__4543316F] DEFAULT (0) NULL,
    [CheckAmtFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblApPrep__Check__463755A8] DEFAULT (0) NULL,
    [GLCashAcct]      [dbo].[pGlAcct]     NULL,
    [GLDiscAcct]      [dbo].[pGlAcct]     NULL,
    [GlPeriod]        SMALLINT            CONSTRAINT [DF__tblApPrep__GlPer__4913C253] DEFAULT (0) NULL,
    [FiscalYear]      SMALLINT            CONSTRAINT [DF__tblApPrep__Fisca__4A07E68C] DEFAULT (0) NULL,
    [TermsCode]       [dbo].[pTermsCode]  NULL,
    [ts]              ROWVERSION          NULL,
    [BankID]          [dbo].[pBankID]     NULL,
    [GrossAmtDueChk]  [dbo].[pDec]        DEFAULT ((0)) NULL,
    [BaseGrossAmtDue] [dbo].[pDec]        DEFAULT ((0)) NULL,
    [PmtCurrencyId]   [dbo].[pCurrency]   NULL,
    [PmtExchRate]     [dbo].[pDec]        DEFAULT ((1)) NOT NULL,
    [CalcGainLoss]    [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [GLAccGainLoss]   [dbo].[pGlAcct]     NULL,
    [BatchID]         [dbo].[pBatchID]    DEFAULT ('######') NOT NULL,
    [GrpID]           INT                 DEFAULT ((0)) NOT NULL,
    [Notes]           TEXT                NULL,
    [PageFlag]        TINYINT             DEFAULT ((0)) NOT NULL,
    [PrintCounter]    INT                 DEFAULT ((0)) NULL,
    CONSTRAINT [PK__tblApPrepChkInvc__084B3915] PRIMARY KEY CLUSTERED ([VendorID] ASC, [InvoiceNum] ASC, [Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlVendorID]
    ON [dbo].[tblApPrepChkInvc]([VendorID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlInvoiceNum]
    ON [dbo].[tblApPrepChkInvc]([InvoiceNum] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlCounter]
    ON [dbo].[tblApPrepChkInvc]([Counter] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApPrepChkInvc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApPrepChkInvc';

