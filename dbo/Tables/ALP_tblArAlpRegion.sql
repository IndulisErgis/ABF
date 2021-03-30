CREATE TABLE [dbo].[ALP_tblArAlpRegion] (
    [Region]   VARCHAR (10)  NOT NULL,
    [Name]     VARCHAR (255) NULL,
    [NotifyYN] BIT           CONSTRAINT [DF_tblArAlpRegion_NotifyYN] DEFAULT (0) NULL,
    [ts]       ROWVERSION    NULL,
    CONSTRAINT [PK_tblArAlpRegion] PRIMARY KEY CLUSTERED ([Region] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpRegion] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpRegion] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpRegion] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpRegion] TO PUBLIC
    AS [dbo];

