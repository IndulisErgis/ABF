CREATE TABLE [dbo].[tblHrPropertyCode] (
    [ID]          BIGINT        NOT NULL,
    [Description] NVARCHAR (50) NOT NULL,
    [CF]          XML           NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblHrPropertyCode] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrPropertyCode_Description]
    ON [dbo].[tblHrPropertyCode]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrPropertyCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrPropertyCode';

