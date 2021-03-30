CREATE TABLE [dbo].[tblPcInvoiceTax] (
    [TransId]       [dbo].[pTransID] NOT NULL,
    [TaxLocID]      [dbo].[pTaxLoc]  NOT NULL,
    [TaxClass]      TINYINT          CONSTRAINT [DF_tblPcInvoiceTax_TaxClass] DEFAULT ((0)) NOT NULL,
    [Level]         TINYINT          CONSTRAINT [DF_tblPcInvoiceTax_Level] DEFAULT ((1)) NOT NULL,
    [TaxAmt]        [dbo].[pDec]     CONSTRAINT [DF_tblPcInvoiceTax_TaxAmt] DEFAULT ((0)) NOT NULL,
    [TaxAmtFgn]     [dbo].[pDec]     CONSTRAINT [DF_tblPcInvoiceTax_TaxAmtFgn] DEFAULT ((0)) NOT NULL,
    [Taxable]       [dbo].[pDec]     CONSTRAINT [DF_tblPcInvoiceTax_Taxable] DEFAULT ((0)) NOT NULL,
    [TaxableFgn]    [dbo].[pDec]     CONSTRAINT [DF_tblPcInvoiceTax_TaxableFgn] DEFAULT ((0)) NOT NULL,
    [NonTaxable]    [dbo].[pDec]     CONSTRAINT [DF_tblPcInvoiceTax_NonTaxable] DEFAULT ((0)) NOT NULL,
    [NonTaxableFgn] [dbo].[pDec]     CONSTRAINT [DF_tblPcInvoiceTax_NonTaxableFgn] DEFAULT ((0)) NOT NULL,
    [LiabilityAcct] [dbo].[pGlAcct]  NULL,
    [CF]            XML              NULL,
    [ts]            ROWVERSION       NULL,
    CONSTRAINT [PK_tblPcInvoiceTax] PRIMARY KEY CLUSTERED ([TransId] ASC, [TaxLocID] ASC, [TaxClass] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcInvoiceTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcInvoiceTax';

