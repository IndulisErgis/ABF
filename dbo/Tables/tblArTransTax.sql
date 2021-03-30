CREATE TABLE [dbo].[tblArTransTax] (
    [TransId]       [dbo].[pTransID] NOT NULL,
    [TaxLocID]      [dbo].[pTaxLoc]  NOT NULL,
    [TaxClass]      TINYINT          CONSTRAINT [DF__tblArTran__TaxCl__76C57E6A] DEFAULT (0) NOT NULL,
    [Level]         TINYINT          CONSTRAINT [DF__tblArTran__Level__77B9A2A3] DEFAULT (1) NULL,
    [TaxAmt]        [dbo].[pDec]     CONSTRAINT [DF_tblArTransTax_TaxAmt] DEFAULT (0) NULL,
    [TaxAmtFgn]     [dbo].[pDec]     CONSTRAINT [DF_tblArTransTax_TaxAmtFgn] DEFAULT (0) NULL,
    [Taxable]       [dbo].[pDec]     CONSTRAINT [DF_tblArTransTax_Taxable] DEFAULT (0) NULL,
    [TaxableFgn]    [dbo].[pDec]     CONSTRAINT [DF_tblArTransTax_TaxableFgn] DEFAULT (0) NULL,
    [NonTaxable]    [dbo].[pDec]     CONSTRAINT [DF_tblArTransTax_NonTaxable] DEFAULT (0) NULL,
    [NonTaxableFgn] [dbo].[pDec]     CONSTRAINT [DF_tblArTransTax_NonTaxableFgn] DEFAULT (0) NULL,
    [LiabilityAcct] [dbo].[pGlAcct]  NULL,
    [ts]            ROWVERSION       NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK__tblArTransTax__75D15A31] PRIMARY KEY CLUSTERED ([TransId] ASC, [TaxLocID] ASC, [TaxClass] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArTransTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArTransTax';

