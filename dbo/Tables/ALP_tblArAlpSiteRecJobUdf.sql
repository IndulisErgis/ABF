CREATE TABLE [dbo].[ALP_tblArAlpSiteRecJobUdf] (
    [RecJobEntryUdfId] INT           IDENTITY (1, 1) NOT NULL,
    [RecJobEntryId]    INT           NULL,
    [UDFId]            INT           NULL,
    [Value]            VARCHAR (255) NULL,
    [ts]               ROWVERSION    NULL,
    CONSTRAINT [PK_tblJmRecJobUdf] PRIMARY KEY CLUSTERED ([RecJobEntryUdfId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecJobUdf] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecJobUdf] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecJobUdf] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecJobUdf] TO PUBLIC
    AS [dbo];

