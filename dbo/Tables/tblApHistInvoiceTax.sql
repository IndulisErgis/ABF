CREATE TABLE [dbo].[tblApHistInvoiceTax] (
    [PostRun]       [dbo].[pPostRun]    CONSTRAINT [DF__tblApHist__PostR__588B100D] DEFAULT (0) NOT NULL,
    [TransId]       [dbo].[pTransID]    NOT NULL,
    [InvcNum]       [dbo].[pInvoiceNum] NOT NULL,
    [TaxLocID]      [dbo].[pTaxLoc]     NOT NULL,
    [TaxClass]      TINYINT             CONSTRAINT [DF__tblApHist__TaxCl__597F3446] DEFAULT (0) NOT NULL,
    [ExpAcct]       [dbo].[pGlAcct]     NOT NULL,
    [TaxAmt]        [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__5A73587F] DEFAULT (0) NULL,
    [Refundable]    [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Refun__5B677CB8] DEFAULT (0) NULL,
    [Taxable]       [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Taxab__5C5BA0F1] DEFAULT (0) NULL,
    [NonTaxable]    [dbo].[pDec]        CONSTRAINT [DF__tblApHist__NonTa__5D4FC52A] DEFAULT (0) NULL,
    [RefundAcct]    [dbo].[pGlAcct]     NULL,
    [TaxAmtFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__5E43E963] DEFAULT (0) NULL,
    [TaxableFgn]    [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Taxab__5F380D9C] DEFAULT (0) NULL,
    [NonTaxableFgn] [dbo].[pDec]        CONSTRAINT [DF__tblApHist__NonTa__602C31D5] DEFAULT (0) NULL,
    [RefundableFgn] [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Refun__6120560E] DEFAULT (0) NULL,
    [CF]            XML                 NULL,
    CONSTRAINT [PK__tblApHistInvoice__019E3B86] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [InvcNum] ASC, [TaxLocID] ASC, [TaxClass] ASC, [ExpAcct] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqltblApHistInvoiceTaxPostRun]
    ON [dbo].[tblApHistInvoiceTax]([PostRun] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblApHistInvoiceTax] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblApHistInvoiceTax] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblApHistInvoiceTax] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblApHistInvoiceTax] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistInvoiceTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistInvoiceTax';

