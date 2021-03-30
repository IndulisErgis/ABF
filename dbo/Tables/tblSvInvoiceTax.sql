CREATE TABLE [dbo].[tblSvInvoiceTax] (
    [TransID]       [dbo].[pTransID] NOT NULL,
    [TaxLocID]      [dbo].[pTaxLoc]  NOT NULL,
    [TaxClass]      TINYINT          DEFAULT ((0)) NOT NULL,
    [Level]         TINYINT          DEFAULT ((1)) NOT NULL,
    [TaxAmt]        [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [TaxAmtFgn]     [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [Taxable]       [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [TaxableFgn]    [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [NonTaxable]    [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [NonTaxableFgn] [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [LiabilityAcct] [dbo].[pGlAcct]  NULL,
    [CF]            XML              NULL,
    [ts]            ROWVERSION       NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvInvoiceTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvInvoiceTax';

