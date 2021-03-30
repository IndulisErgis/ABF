CREATE TABLE [dbo].[tblPsHistTax] (
    [ID]              BIGINT           NOT NULL,
    [HeaderID]        BIGINT           NOT NULL,
    [TaxLocID]        [dbo].[pTaxLoc]  NOT NULL,
    [TaxClass]        TINYINT          NOT NULL,
    [TaxLevel]        TINYINT          NOT NULL,
    [TaxAmt]          [dbo].[pDecimal] NOT NULL,
    [Taxable]         [dbo].[pDecimal] NOT NULL,
    [NonTaxable]      [dbo].[pDecimal] NOT NULL,
    [GLAcctLiability] [dbo].[pGlAcct]  NULL,
    [CF]              XML              NULL,
    CONSTRAINT [PK_tblPsHistTax] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsHistTax_HeaderIDTaxLocIDTaxClass]
    ON [dbo].[tblPsHistTax]([HeaderID] ASC, [TaxLocID] ASC, [TaxClass] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsHistTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsHistTax';

