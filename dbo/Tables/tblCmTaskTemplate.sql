CREATE TABLE [dbo].[tblCmTaskTemplate] (
    [TemplateId]  NVARCHAR (20) NOT NULL,
    [Description] NVARCHAR (80) NULL,
    [CF]          XML           NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblCmTaskTemplate] PRIMARY KEY CLUSTERED ([TemplateId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmTaskTemplate';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCmTaskTemplate';

