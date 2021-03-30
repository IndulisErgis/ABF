CREATE TABLE [dbo].[tblSysCatalogRoles] (
    [ID]           BIGINT     IDENTITY (1, 1) NOT NULL,
    [CatalogDefId] BIGINT     NOT NULL,
    [RoleId]       INT        NOT NULL,
    [ts]           ROWVERSION NULL,
    CONSTRAINT [PK_tblSysCatalogRoles] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCatalogRoles';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCatalogRoles';

