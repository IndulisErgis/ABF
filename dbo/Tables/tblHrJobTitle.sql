CREATE TABLE [dbo].[tblHrJobTitle] (
    [ID]               BIGINT        NOT NULL,
    [Description]      NVARCHAR (50) NOT NULL,
    [JobCatTypeCodeID] BIGINT        NULL,
    [CF]               XML           NULL,
    [ts]               ROWVERSION    NULL,
    CONSTRAINT [PK_tblHrJobTitle] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblHrJobTitle_Description]
    ON [dbo].[tblHrJobTitle]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrJobTitle';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblHrJobTitle';

