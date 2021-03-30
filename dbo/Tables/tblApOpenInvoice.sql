CREATE TABLE [dbo].[tblApOpenInvoice] (
    [Counter]         INT                 IDENTITY (1, 1) NOT NULL,
    [VendorID]        [dbo].[pVendorID]   NOT NULL,
    [InvoiceNum]      [dbo].[pInvoiceNum] NOT NULL,
    [Status]          TINYINT             CONSTRAINT [DF__tblApOpen__Statu__761B72F4] DEFAULT (0) NULL,
    [Ten99InvoiceYN]  BIT                 CONSTRAINT [DF__tblApOpen__Ten99__770F972D] DEFAULT (0) NULL,
    [DistCode]        [dbo].[pDistCode]   NULL,
    [InvoiceDate]     DATETIME            CONSTRAINT [DF__tblApOpen__Invoi__7803BB66] DEFAULT (getdate()) NULL,
    [DiscDueDate]     DATETIME            NULL,
    [NetDueDate]      DATETIME            NULL,
    [GrossAmtDue]     [dbo].[pDec]        CONSTRAINT [DF__tblApOpen__Gross__78F7DF9F] DEFAULT (0) NULL,
    [DiscAmt]         [dbo].[pDec]        CONSTRAINT [DF__tblApOpen__DiscA__79EC03D8] DEFAULT (0) NULL,
    [GrossAmtDueFgn]  [dbo].[pDec]        CONSTRAINT [DF__tblApOpen__Gross__7AE02811] DEFAULT (0) NULL,
    [DiscAmtFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApOpen__DiscA__7BD44C4A] DEFAULT (0) NULL,
    [CheckNum]        [dbo].[pCheckNum]   NULL,
    [CheckDate]       DATETIME            NULL,
    [CurrencyId]      [dbo].[pCurrency]   NOT NULL,
    [ExchRate]        [dbo].[pDec]        CONSTRAINT [DF__tblApOpenInvoice_ExchRate] DEFAULT ((1)) NULL,
    [GlPeriod]        SMALLINT            CONSTRAINT [DF__tblApOpen__GlPer__7DBC94BC] DEFAULT (0) NULL,
    [FiscalYear]      SMALLINT            CONSTRAINT [DF__tblApOpen__Fisca__7EB0B8F5] DEFAULT (0) NULL,
    [CheckPeriod]     SMALLINT            CONSTRAINT [DF__tblApOpen__Check__79F7BC27] DEFAULT (0) NULL,
    [CheckYear]       SMALLINT            CONSTRAINT [DF__tblApOpen__Check__790397EE] DEFAULT (0) NULL,
    [TermsCode]       [dbo].[pTermsCode]  NULL,
    [VoidCreatedDate] DATETIME            NULL,
    [ts]              ROWVERSION          NULL,
    [BankID]          [dbo].[pBankID]     NULL,
    [BaseGrossAmtDue] [dbo].[pDec]        DEFAULT ((0)) NULL,
    [PmtCurrencyId]   [dbo].[pCurrency]   NULL,
    [PmtExchRate]     [dbo].[pDec]        CONSTRAINT [DF_tblApOpenInvoice_PmtExchRate] DEFAULT ((1)) NULL,
    [CalcGainLoss]    [dbo].[pDec]        DEFAULT ((0)) NULL,
    [GLAccGainLoss]   [dbo].[pGlAcct]     NULL,
    [Notes]           TEXT                NULL,
    [PostRun]         [dbo].[pPostRun]    NULL,
    [TransID]         NVARCHAR (255)      NULL,
    [CF]              XML                 NULL,
    [GroupID]         INT                 NULL,
    CONSTRAINT [PK__tblApOpenInvoice__75274EBB] PRIMARY KEY NONCLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblApOpenInvoice_Status]
    ON [dbo].[tblApOpenInvoice]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlInvoiceNum]
    ON [dbo].[tblApOpenInvoice]([InvoiceNum] ASC) WITH (FILLFACTOR = 80);


GO
CREATE CLUSTERED INDEX [sqlVendorID]
    ON [dbo].[tblApOpenInvoice]([VendorID] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApOpenInvoice';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApOpenInvoice';

