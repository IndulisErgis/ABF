CREATE TABLE [dbo].[tblApTransInvoiceTax] (
    [TransId]       [dbo].[pTransID]    NOT NULL,
    [TaxLocID]      [dbo].[pTaxLoc]     NOT NULL,
    [TaxClass]      TINYINT             CONSTRAINT [DF__tblApTran__TaxCl__5BF18C9D] DEFAULT (0) NOT NULL,
    [ExpAcct]       [dbo].[pGlAcct]     NOT NULL,
    [TaxAmt]        [dbo].[pDec]        CONSTRAINT [DF__tblApTran__TaxAm__5CE5B0D6] DEFAULT (0) NULL,
    [Refundable]    [dbo].[pDec]        CONSTRAINT [DF__tblApTran__Refun__5DD9D50F] DEFAULT (0) NULL,
    [Taxable]       [dbo].[pDec]        CONSTRAINT [DF__tblApTran__Taxab__5ECDF948] DEFAULT (0) NULL,
    [NonTaxable]    [dbo].[pDec]        CONSTRAINT [DF__tblApTran__NonTa__5FC21D81] DEFAULT (0) NULL,
    [RefundAcct]    [dbo].[pGlAcct]     NULL,
    [InvcNum]       [dbo].[pInvoiceNum] NULL,
    [TaxAmtFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblApTran__TaxAm__60B641BA] DEFAULT (0) NULL,
    [TaxableFgn]    [dbo].[pDec]        CONSTRAINT [DF__tblApTran__Taxab__61AA65F3] DEFAULT (0) NULL,
    [NonTaxableFgn] [dbo].[pDec]        CONSTRAINT [DF__tblApTran__NonTa__629E8A2C] DEFAULT (0) NULL,
    [RefundableFgn] [dbo].[pDec]        CONSTRAINT [DF__tblApTran__Refun__6392AE65] DEFAULT (0) NULL,
    [ts]            ROWVERSION          NULL,
    [Level]         TINYINT             CONSTRAINT [DF__tblApTran__Level__77B9A2A3] DEFAULT ((1)) NOT NULL,
    [CF]            XML                 NULL,
    CONSTRAINT [PK__tblApTransInvoic__1699586C] PRIMARY KEY CLUSTERED ([TransId] ASC, [TaxLocID] ASC, [TaxClass] ASC, [ExpAcct] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransInvoiceTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransInvoiceTax';

