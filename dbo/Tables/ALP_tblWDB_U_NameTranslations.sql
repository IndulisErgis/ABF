CREATE TABLE [dbo].[ALP_tblWDB_U_NameTranslations] (
    [ID]      INT          IDENTITY (1, 1) NOT NULL,
    [TextIn]  VARCHAR (50) NOT NULL,
    [TextOut] VARCHAR (50) NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblWDB_U_NameTranslations]
    ON [dbo].[ALP_tblWDB_U_NameTranslations]([TextIn] ASC) WITH (FILLFACTOR = 80);

