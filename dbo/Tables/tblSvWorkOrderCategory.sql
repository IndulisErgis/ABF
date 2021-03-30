CREATE TABLE [dbo].[tblSvWorkOrderCategory] (
    [ID]           BIGINT               NOT NULL,
    [CategoryCode] NVARCHAR (10)        NOT NULL,
    [Description]  [dbo].[pDescription] NULL,
    [CF]           XML                  NULL,
    [ts]           ROWVERSION           NULL,
    CONSTRAINT [PK_tblSvWorkOrderCategory] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSvWorkOrderCategory_CategoryCode]
    ON [dbo].[tblSvWorkOrderCategory]([CategoryCode] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderCategory';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWorkOrderCategory';

