CREATE TABLE [dbo].[tblPsTransTax] (
    [ID]         BIGINT           NOT NULL,
    [HeaderID]   BIGINT           NOT NULL,
    [TaxLocID]   [dbo].[pTaxLoc]  NOT NULL,
    [TaxClass]   TINYINT          NOT NULL,
    [TaxLevel]   TINYINT          NOT NULL,
    [TaxAmt]     [dbo].[pDecimal] NOT NULL,
    [Taxable]    [dbo].[pDecimal] NOT NULL,
    [NonTaxable] [dbo].[pDecimal] NOT NULL,
    [CF]         XML              NULL,
    [ts]         ROWVERSION       NULL,
    CONSTRAINT [PK_tblPsTransTax] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsTransTax_HeaderIDTaxLocIDTaxClass]
    ON [dbo].[tblPsTransTax]([HeaderID] ASC, [TaxLocID] ASC, [TaxClass] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTransTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTransTax';

