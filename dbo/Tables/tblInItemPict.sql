CREATE TABLE [dbo].[tblInItemPict] (
    [PictId]   VARCHAR (10)  NOT NULL,
    [PictItem] IMAGE         NULL,
    [ImageURL] VARCHAR (255) NULL,
    [Descr]    VARCHAR (35)  NULL,
    [ts]       ROWVERSION    NULL,
    [PictType] TINYINT       DEFAULT ((0)) NOT NULL,
    [CF]       XML           NULL,
    PRIMARY KEY CLUSTERED ([PictId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemPict] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemPict';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemPict';

