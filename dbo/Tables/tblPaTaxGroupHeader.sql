CREATE TABLE [dbo].[tblPaTaxGroupHeader] (
    [ID]          BIGINT               NOT NULL,
    [TaxGroup]    [dbo].[pTaxLoc]      NOT NULL,
    [Description] [dbo].[pDescription] NULL,
    [CF]          XML                  NULL,
    [ts]          ROWVERSION           NULL,
    CONSTRAINT [PK_tblPaTaxGroupHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaTaxGroupHeader_TaxGroup]
    ON [dbo].[tblPaTaxGroupHeader]([TaxGroup] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxGroupHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxGroupHeader';

