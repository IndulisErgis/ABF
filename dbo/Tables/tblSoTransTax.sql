CREATE TABLE [dbo].[tblSoTransTax] (
    [TransId]       [dbo].[pTransID] NOT NULL,
    [TaxLocID]      [dbo].[pTaxLoc]  NOT NULL,
    [TaxClass]      TINYINT          CONSTRAINT [DF__tblSoTran__TaxCl__136CAA10] DEFAULT (0) NOT NULL,
    [Level]         TINYINT          CONSTRAINT [DF__tblSoTran__Level__1460CE49] DEFAULT (1) NULL,
    [TaxAmt]        [dbo].[pDec]     CONSTRAINT [DF_tblSoTransTax_TaxAmt] DEFAULT (0) NULL,
    [TaxAmtFgn]     [dbo].[pDec]     CONSTRAINT [DF_tblSoTransTax_TaxAmtFgn] DEFAULT (0) NULL,
    [Taxable]       [dbo].[pDec]     CONSTRAINT [DF_tblSoTransTax_Taxable] DEFAULT (0) NULL,
    [TaxableFgn]    [dbo].[pDec]     CONSTRAINT [DF_tblSoTransTax_TaxableFgn] DEFAULT (0) NULL,
    [NonTaxable]    [dbo].[pDec]     CONSTRAINT [DF_tblSoTransTax_NonTaxable] DEFAULT (0) NULL,
    [NonTaxableFgn] [dbo].[pDec]     CONSTRAINT [DF_tblSoTransTax_NonTaxableFgn] DEFAULT (0) NULL,
    [LiabilityAcct] [dbo].[pGlAcct]  NULL,
    [ts]            ROWVERSION       NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK__tblSoTransTax__127885D7] PRIMARY KEY CLUSTERED ([TransId] ASC, [TaxLocID] ASC, [TaxClass] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblSoTransTax] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoTransTax] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoTransTax] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblSoTransTax] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransTax';

