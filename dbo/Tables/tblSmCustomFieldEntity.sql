CREATE TABLE [dbo].[tblSmCustomFieldEntity] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [FieldId]    INT            NOT NULL,
    [EntityName] NVARCHAR (255) NOT NULL,
    [Layout]     XML            NULL,
    CONSTRAINT [PK_tblSmCustomFieldEntity] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmCustomFieldEntity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmCustomFieldEntity';

