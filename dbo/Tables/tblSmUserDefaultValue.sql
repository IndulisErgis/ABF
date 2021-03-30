CREATE TABLE [dbo].[tblSmUserDefaultValue] (
    [Id]           INT              IDENTITY (1, 1) NOT NULL,
    [DefaultId]    UNIQUEIDENTIFIER NOT NULL,
    [ContextType]  TINYINT          NOT NULL,
    [ContextId]    NVARCHAR (255)   NOT NULL,
    [DefaultValue] NVARCHAR (255)   NULL,
    CONSTRAINT [PK_tblSmUserDefaultValue] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSmUserDefaultValue_DefaultIdContextTypeContextID]
    ON [dbo].[tblSmUserDefaultValue]([DefaultId] ASC, [ContextType] ASC, [ContextId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmUserDefaultValue';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmUserDefaultValue';

