CREATE TABLE [dbo].[tblSysCustomSchema] (
    [ID]          UNIQUEIDENTIFIER NOT NULL,
    [TableName]   NVARCHAR (255)   NOT NULL,
    [FieldName]   NVARCHAR (255)   NOT NULL,
    [FieldLength] SMALLINT         NOT NULL,
    CONSTRAINT [PK_tblSysCustomSchema] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSysCustomSchema_TableNameFieldName]
    ON [dbo].[tblSysCustomSchema]([TableName] ASC, [FieldName] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCustomSchema';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysCustomSchema';

