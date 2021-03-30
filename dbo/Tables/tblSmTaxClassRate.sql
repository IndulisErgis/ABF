CREATE TABLE [dbo].[tblSmTaxClassRate] (
    [TaxClassRateID] INT             IDENTITY (1, 1) NOT NULL,
    [TaxLocId]       [dbo].[pTaxLoc] NOT NULL,
    [TaxClassCode]   TINYINT         NOT NULL,
    [RangeThru]      [dbo].[pDec]    NOT NULL,
    [TaxSales]       [dbo].[pDec]    CONSTRAINT [DF_tblSmTaxClassRate_TaxSales] DEFAULT ((0)) NOT NULL,
    [TaxPurch]       [dbo].[pDec]    CONSTRAINT [DF_tblSmTaxClassRate_TaxPurch] DEFAULT ((0)) NOT NULL,
    [TaxRefund]      [dbo].[pDec]    CONSTRAINT [DF_tblSmTaxClassRate_TaxRefund] DEFAULT ((0)) NOT NULL,
    [TaxType]        TINYINT         CONSTRAINT [DF_tblSmTaxClassRate_TaxType] DEFAULT ((0)) NOT NULL,
    [CF]             XML             NULL,
    CONSTRAINT [PK_tblSmTaxClassRate] PRIMARY KEY CLUSTERED ([TaxClassRateID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmTaxClassRate]
    ON [dbo].[tblSmTaxClassRate]([TaxLocId] ASC, [TaxClassCode] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxClassRate';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTaxClassRate';

