CREATE TABLE [dbo].[ALP_tblArAlpUDFSites] (
    [SiteId] INT           NOT NULL,
    [UDFId]  INT           NOT NULL,
    [Value]  VARCHAR (255) NULL,
    [ts]     ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpUDFSites] PRIMARY KEY CLUSTERED ([SiteId] ASC, [UDFId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpUDFSites] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpUDFSites] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpUDFSites] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpUDFSites] TO PUBLIC
    AS [dbo];

