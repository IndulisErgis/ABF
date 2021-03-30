CREATE TABLE [dbo].[ALP_tblWDB_U_RemoveChars] (
    [id]     BIGINT      IDENTITY (1, 1) NOT NULL,
    [TextIn] VARCHAR (1) NOT NULL
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblWDB_U_RemoveChars]
    ON [dbo].[ALP_tblWDB_U_RemoveChars]([TextIn] ASC) WITH (FILLFACTOR = 80);

