CREATE TABLE [dbo].[ALP_tblArAlpCounty] (
    [County] VARCHAR (50) NOT NULL,
    [Region] VARCHAR (10) NOT NULL,
    [ts]     ROWVERSION   NULL,
    CONSTRAINT [PK_tblArAlpCounty] PRIMARY KEY CLUSTERED ([County] ASC, [Region] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpCounty] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpCounty] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpCounty] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpCounty] TO PUBLIC
    AS [dbo];

