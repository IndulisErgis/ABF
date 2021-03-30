CREATE TABLE [dbo].[tblApCheckHist] (
    [Counter]         INT                 IDENTITY (1, 1) NOT NULL,
    [PostRun]         [dbo].[pPostRun]    CONSTRAINT [DF__tblApChec__PostR__049E9C75] DEFAULT (0) NULL,
    [VendorID]        [dbo].[pVendorID]   NULL,
    [InvoiceNum]      [dbo].[pInvoiceNum] NULL,
    [PmtType]         TINYINT             CONSTRAINT [DF__tblApChec__PmtTy__0592C0AE] DEFAULT (0) NULL,
    [GrossAmtDue]     [dbo].[pDec]        CONSTRAINT [DF__tblApChec__Gross__0686E4E7] DEFAULT (0) NULL,
    [DiscAmt]         [dbo].[pDec]        CONSTRAINT [DF__tblApChec__DiscA__077B0920] DEFAULT (0) NULL,
    [InvoiceDate]     DATETIME            NULL,
    [CheckDate]       DATETIME            NULL,
    [VoidDate]        DATETIME            NULL,
    [CheckNum]        [dbo].[pCheckNum]   NULL,
    [GLCashAcct]      [dbo].[pGlAcct]     NULL,
    [GLDiscAcct]      [dbo].[pGlAcct]     NULL,
    [GrossAmtDueFgn]  [dbo].[pDec]        CONSTRAINT [DF__tblApChec__Gross__086F2D59] DEFAULT (0) NULL,
    [DiscAmtFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApChec__DiscA__09635192] DEFAULT (0) NULL,
    [CurrencyID]      [dbo].[pCurrency]   NULL,
    [Ten99InvoiceYN]  BIT                 CONSTRAINT [DF__tblApChec__Ten99__0A5775CB] DEFAULT (0) NULL,
    [DistCode]        [dbo].[pDistCode]   NULL,
    [VoidYn]          BIT                 CONSTRAINT [DF__tblApChec__VoidY__0B4B9A04] DEFAULT (0) NULL,
    [SelectedYn]      BIT                 CONSTRAINT [DF__tblApChec__Selec__0C3FBE3D] DEFAULT (0) NULL,
    [DiscDueDate]     DATETIME            NULL,
    [NetDueDate]      DATETIME            NULL,
    [ExchRate]        [dbo].[pDec]        CONSTRAINT [DF__tblApCheckHist_ExchRate] DEFAULT ((1)) NULL,
    [BankId]          [dbo].[pBankID]     NULL,
    [VoidBankId]      [dbo].[pBankID]     NULL,
    [CheckRun]        DATETIME            NULL,
    [DiscLost]        [dbo].[pDec]        CONSTRAINT [DF__tblApChec__DiscL__0E2806AF] DEFAULT (0) NULL,
    [DiscTaken]       [dbo].[pDec]        CONSTRAINT [DF__tblApChec__DiscT__0F1C2AE8] DEFAULT (0) NULL,
    [DiscLostFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblApChec__DiscL__10104F21] DEFAULT (0) NULL,
    [DiscTakenFgn]    [dbo].[pDec]        CONSTRAINT [DF__tblApChec__DiscT__1104735A] DEFAULT (0) NULL,
    [GlPeriod]        SMALLINT            CONSTRAINT [DF__tblApChec__GlPer__11F89793] DEFAULT (0) NULL,
    [FiscalYear]      SMALLINT            CONSTRAINT [DF__tblApChec__Fisca__12ECBBCC] DEFAULT (0) NULL,
    [Ten99FormCode]   VARCHAR (1)         NULL,
    [TermsCode]       [dbo].[pTermsCode]  NULL,
    [SumHistPeriod]   SMALLINT            CONSTRAINT [DF_tblApCheckHist_SumHistPeriod] DEFAULT (0) NULL,
    [PayToName]       VARCHAR (30)        NULL,
    [PayToAttn]       VARCHAR (30)        NULL,
    [PayToAddr1]      VARCHAR (30)        NULL,
    [PayToAddr2]      VARCHAR (60)        NULL,
    [PayToCity]       VARCHAR (30)        NULL,
    [PayToRegion]     VARCHAR (10)        NULL,
    [PayToCountry]    [dbo].[pCountry]    NULL,
    [PayToPostalCode] VARCHAR (10)        NULL,
    [BaseGrossAmtDue] [dbo].[pDec]        DEFAULT ((0)) NULL,
    [PmtCurrencyID]   [dbo].[pCurrency]   NULL,
    [PmtExchRate]     [dbo].[pDec]        DEFAULT ((1)) NULL,
    [NetPaidCalc]     [dbo].[pDec]        DEFAULT ((0)) NULL,
    [DiscAmtCalc]     [dbo].[pDec]        DEFAULT ((0)) NULL,
    [DeliveryType]    TINYINT             DEFAULT ((0)) NULL,
    [BankAcctNum]     NVARCHAR (255)      NULL,
    [RoutingCode]     VARCHAR (9)         NULL,
    [GLAcctAP]        [dbo].[pGlAcct]     NULL,
    [GLAcctGainLoss]  [dbo].[pGlAcct]     NULL,
    [CF]              XML                 NULL,
    [BankAccountType] TINYINT             CONSTRAINT [DF_tblApCheckHist_BankAccountType] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__tblApCheckHist__7CD98669] PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlVendorID]
    ON [dbo].[tblApCheckHist]([VendorID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlInvoiceNum]
    ON [dbo].[tblApCheckHist]([InvoiceNum] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlCheckRun]
    ON [dbo].[tblApCheckHist]([CheckRun] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlCheckNum]
    ON [dbo].[tblApCheckHist]([CheckNum] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApCheckHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApCheckHist';

