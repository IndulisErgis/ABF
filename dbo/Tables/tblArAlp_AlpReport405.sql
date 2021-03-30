CREATE TABLE [dbo].[tblArAlp_AlpReport405] (
    [SiteID]        INT          NOT NULL,
    [SubdivisionID] INT          NULL,
    [MonStatus]     VARCHAR (30) NULL,
    [ts]            ROWVERSION   NULL,
    CONSTRAINT [PK_tblArAlp_AlpReport405] PRIMARY KEY CLUSTERED ([SiteID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblArAlp_AlpReport405] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArAlp_AlpReport405] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblArAlp_AlpReport405] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblArAlp_AlpReport405] TO PUBLIC
    AS [dbo];

