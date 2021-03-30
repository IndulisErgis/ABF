CREATE TABLE [dbo].[tblInSalesCat] (
    [SalesCat] CHAR (2)     NOT NULL,
    [Descr]    VARCHAR (35) NULL,
    [ts]       ROWVERSION   NULL,
    [CF]       XML          NULL,
    CONSTRAINT [PK__tblInSalesCat__33008CF0] PRIMARY KEY CLUSTERED ([SalesCat] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInSalesCat';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInSalesCat';

