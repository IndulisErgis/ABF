CREATE TABLE [dbo].[tblSmTaxLocDetail] (
    [TaxLocId]     [dbo].[pTaxLoc] NOT NULL,
    [TaxClassCode] TINYINT         CONSTRAINT [DF__tblSmTaxL__TaxCl__69EAA639] DEFAULT (0) NOT NULL,
    [TaxableYn]    BIT             CONSTRAINT [DF__tblSmTaxL__Taxab__6ADECA72] DEFAULT (1) NULL,
    [SalesTaxPct]  [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__Sales__6BD2EEAB] DEFAULT (0) NULL,
    [PurchTaxPct]  [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__Purch__6CC712E4] DEFAULT (0) NULL,
    [RefundPct]    [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__Refun__6DBB371D] DEFAULT (0) NULL,
    [TaxSales]     [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__TaxSa__6EAF5B56] DEFAULT (0) NULL,
    [NonTaxSales]  [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__NonTa__6FA37F8F] DEFAULT (0) NULL,
    [TaxCollect]   [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__TaxCo__7097A3C8] DEFAULT (0) NULL,
    [TaxPurch]     [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__TaxPu__718BC801] DEFAULT (0) NULL,
    [NonTaxPurch]  [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__NonTa__727FEC3A] DEFAULT (0) NULL,
    [TaxCalc]      [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__TaxCa__73741073] DEFAULT (0) NULL,
    [TaxPaid]      [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__TaxPa__746834AC] DEFAULT (0) NULL,
    [TaxRefund]    [dbo].[pDec]    CONSTRAINT [DF__tblSmTaxL__TaxRe__755C58E5] DEFAULT (0) NULL,
    [ExpenseAcct]  [dbo].[pGlAcct] NULL,
    [ts]           ROWVERSION      NULL,
    [CalcMethod]   TINYINT         NULL,
    [CF]           XML             NULL,
    CONSTRAINT [PK__tblSmTaxLocDetai__190BB0C3] PRIMARY KEY CLUSTERED ([TaxLocId] ASC, [TaxClassCode] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlSecondaryKey]
    ON [dbo].[tblSmTaxLocDetail]([TaxClassCode] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxLocDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxLocDetail';

