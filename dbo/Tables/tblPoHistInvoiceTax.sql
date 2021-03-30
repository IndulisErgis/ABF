CREATE TABLE [dbo].[tblPoHistInvoiceTax] (
    [EntryNum]          INT                 IDENTITY (1, 1) NOT NULL,
    [PostRun]           [dbo].[pPostRun]    CONSTRAINT [DF__tblPoHist__PostR__7C694927] DEFAULT (0) NULL,
    [TransId]           [dbo].[pTransID]    NOT NULL,
    [InvcNum]           [dbo].[pInvoiceNum] NOT NULL,
    [TaxLocID]          [dbo].[pTaxLoc]     NOT NULL,
    [TaxClass]          TINYINT             CONSTRAINT [DF__tblPoHist__TaxCl__7D5D6D60] DEFAULT (0) NULL,
    [TaxAmt]            [dbo].[pDec]        CONSTRAINT [DF__tblPoHist__TaxAm__7E519199] DEFAULT (0) NULL,
    [RefundAmt]         [dbo].[pDec]        CONSTRAINT [DF__tblPoHist__Refun__7F45B5D2] DEFAULT (0) NULL,
    [Taxable]           [dbo].[pDec]        CONSTRAINT [DF__tblPoHist__Taxab__0039DA0B] DEFAULT (0) NULL,
    [NonTaxable]        [dbo].[pDec]        CONSTRAINT [DF__tblPoHist__NonTa__012DFE44] DEFAULT (0) NULL,
    [TaxAmtFgn]         [dbo].[pDec]        CONSTRAINT [DF__tblPoHist__TaxAm__0222227D] DEFAULT (0) NULL,
    [RefundAmtFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblPoHist__Refun__031646B6] DEFAULT (0) NULL,
    [TaxableFgn]        [dbo].[pDec]        CONSTRAINT [DF__tblPoHist__Taxab__040A6AEF] DEFAULT (0) NULL,
    [NonTaxableFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblPoHist__NonTa__04FE8F28] DEFAULT (0) NULL,
    [ts]                ROWVERSION          NULL,
    [CurrNonTaxable]    [dbo].[pDec]        NULL,
    [CurrNonTaxableFgn] [dbo].[pDec]        NULL,
    [CurrRefundable]    [dbo].[pDec]        NULL,
    [CurrRefundableFgn] [dbo].[pDec]        NULL,
    [CurrTaxable]       [dbo].[pDec]        NULL,
    [CurrTaxableFgn]    [dbo].[pDec]        NULL,
    [CurrTaxAmt]        [dbo].[pDec]        NULL,
    [CurrTaxAmtFgn]     [dbo].[pDec]        NULL,
    [ExpAcct]           [dbo].[pGlAcct]     NULL,
    [RefundAcct]        [dbo].[pGlAcct]     NULL,
    [CF]                XML                 NULL,
    CONSTRAINT [PK__tblPoHistInvoice__7A8729A3] PRIMARY KEY CLUSTERED ([EntryNum] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPoHistInvoiceTax] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPoHistInvoiceTax] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPoHistInvoiceTax] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPoHistInvoiceTax] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistInvoiceTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistInvoiceTax';

