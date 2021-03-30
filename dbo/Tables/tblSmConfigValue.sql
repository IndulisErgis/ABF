CREATE TABLE [dbo].[tblSmConfigValue] (
    [ConfigValueRef] INT           IDENTITY (1, 1) NOT NULL,
    [ConfigRef]      INT           NOT NULL,
    [RoleId]         VARCHAR (255) NULL,
    [ConfigValue]    VARCHAR (255) NULL,
    CONSTRAINT [PK__tblSmConfigValue] PRIMARY KEY CLUSTERED ([ConfigValueRef] ASC),
    CONSTRAINT [UC_tblSmConfig] UNIQUE NONCLUSTERED ([ConfigValueRef] ASC, [RoleId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmConfigValue';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmConfigValue';

