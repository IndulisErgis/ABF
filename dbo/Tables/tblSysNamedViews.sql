CREATE TABLE [dbo].[tblSysNamedViews] (
    [Id]          INT              IDENTITY (1, 1) NOT NULL,
    [FunctionId]  UNIQUEIDENTIFIER NOT NULL,
    [UserId]      [dbo].[pUserID]  NULL,
    [ViewName]    NVARCHAR (255)   NOT NULL,
    [Description] NVARCHAR (255)   NOT NULL,
    [Layout]      VARBINARY (MAX)  NULL,
    CONSTRAINT [PK_tblSysNamedViews] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysNamedViews';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysNamedViews';

