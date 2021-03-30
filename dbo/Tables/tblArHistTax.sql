CREATE TABLE [dbo].[tblArHistTax] (
    [PostRun]       [dbo].[pPostRun] CONSTRAINT [DF__tblArHist__PostR__01AD2131] DEFAULT (0) NOT NULL,
    [TransId]       [dbo].[pTransID] NOT NULL,
    [TaxLocID]      [dbo].[pTaxLoc]  NOT NULL,
    [TaxClass]      TINYINT          CONSTRAINT [DF__tblArHist__TaxCl__02A1456A] DEFAULT (0) NOT NULL,
    [Level]         TINYINT          CONSTRAINT [DF__tblArHist__Level__039569A3] DEFAULT (1) NULL,
    [TaxAmt]        [dbo].[pDec]     CONSTRAINT [DF_tblArHistTax_TaxAmt] DEFAULT (0) NULL,
    [TaxAmtFgn]     [dbo].[pDec]     CONSTRAINT [DF_tblArHistTax_TaxAmtFgn] DEFAULT (0) NULL,
    [Taxable]       [dbo].[pDec]     CONSTRAINT [DF_tblArHistTax_Taxable] DEFAULT (0) NULL,
    [TaxableFgn]    [dbo].[pDec]     CONSTRAINT [DF_tblArHistTax_TaxableFgn] DEFAULT (0) NULL,
    [NonTaxable]    [dbo].[pDec]     CONSTRAINT [DF_tblArHistTax_NonTaxable] DEFAULT (0) NULL,
    [NonTaxableFgn] [dbo].[pDec]     CONSTRAINT [DF_tblArHistTax_NonTaxableFgn] DEFAULT (0) NULL,
    [LiabilityAcct] [dbo].[pGlAcct]  NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK__tblArHistTax__00B8FCF8] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [TaxLocID] ASC, [TaxClass] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblArHistTax] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArHistTax] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblArHistTax] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblArHistTax] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistTax';

