CREATE TABLE [dbo].[tblSysCustomLayout] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [LayoutId]    NVARCHAR (255)  NOT NULL,
    [UserId]      [dbo].[pUserID] NULL,
    [Description] NVARCHAR (255)  NOT NULL,
    [Layout]      VARBINARY (MAX) NULL,
    CONSTRAINT [PK_tblSysCustomLayout] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [uitblSysCustomLayout]
    ON [dbo].[tblSysCustomLayout]([LayoutId] ASC, [UserId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCustomLayout';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCustomLayout';

