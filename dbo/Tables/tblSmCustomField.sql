CREATE TABLE [dbo].[tblSmCustomField] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [FieldName]  NVARCHAR (50) NOT NULL,
    [Definition] XML           NOT NULL,
    CONSTRAINT [PK_tblSmCustomField] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmCustomField';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Custom field definitions', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmCustomField';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmCustomField';

