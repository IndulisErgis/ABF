CREATE TABLE [dbo].[tblSysCatalog] (
    [ID]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [CatalogDefId] BIGINT         NOT NULL,
    [SearchData]   NVARCHAR (MAX) NULL,
    [ts]           ROWVERSION     NULL,
    CONSTRAINT [PK_tblSysCatalog] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCatalog';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCatalog';

