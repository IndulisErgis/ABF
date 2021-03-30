CREATE TABLE [dbo].[ALP_tblWDB_U_AddressTranslations] (
    [ID]          INT          IDENTITY (1, 1) NOT NULL,
    [TextIn]      VARCHAR (50) NOT NULL,
    [TextOut]     VARCHAR (50) NULL,
    [ReplaceType] VARCHAR (8)  NULL,
    CONSTRAINT [UC_TextInandReplaceType] UNIQUE NONCLUSTERED ([TextIn] ASC, [ReplaceType] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tblWDB_U_AddressTranslations]
    ON [dbo].[ALP_tblWDB_U_AddressTranslations]([TextIn] ASC) WITH (FILLFACTOR = 80);

