CREATE TABLE [dbo].[tblSysCompMenu] (
    [MenuId]       INT            NOT NULL,
    [Descr]        NVARCHAR (50)  NOT NULL,
    [PluginName]   NVARCHAR (255) NULL,
    [AssemblyName] NVARCHAR (255) NULL,
    [ts]           ROWVERSION     NULL,
    CONSTRAINT [PK_tblSysCompMenu] PRIMARY KEY CLUSTERED ([MenuId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCompMenu';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCompMenu';

