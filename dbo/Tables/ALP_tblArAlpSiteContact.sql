CREATE TABLE [dbo].[ALP_tblArAlpSiteContact] (
    [ContactID]      INT           IDENTITY (1, 1) NOT NULL,
    [SiteId]         INT           NULL,
    [Name]           VARCHAR (255) NULL,
    [PrimaryYN]      BIT           CONSTRAINT [DF_ALP_tblArAlpSiteContact_PrimaryYN] DEFAULT ((0)) NOT NULL,
    [Title]          VARCHAR (255) NULL,
    [IntlPrefix]     VARCHAR (6)   NULL,
    [PrimaryPhone]   VARCHAR (15)  NULL,
    [PrimaryExt]     VARCHAR (15)  NULL,
    [PrimaryType]    TINYINT       NULL,
    [OtherPhone]     VARCHAR (15)  NULL,
    [OtherExt]       VARCHAR (15)  NULL,
    [OtherType]      TINYINT       NULL,
    [Fax]            VARCHAR (15)  NULL,
    [Email]          TEXT          NULL,
    [Comments]       TEXT          NULL,
    [FirstName]      VARCHAR (50)  NULL,
    [CreateDate]     DATETIME      NULL,
    [LastUpdateDate] DATETIME      NULL,
    [UploadDate]     DATETIME      NULL,
    [ts]             ROWVERSION    NULL,
    [ModifiedBy]     VARCHAR (50)  NULL,
    [ModifiedDate]   DATETIME      NULL,
    CONSTRAINT [PK_tblArAlpSiteContact] PRIMARY KEY CLUSTERED ([ContactID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_ALP_tblArAlpSiteContact_SiteId]
    ON [dbo].[ALP_tblArAlpSiteContact]([SiteId] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteContact] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteContact] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteContact] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteContact] TO PUBLIC
    AS [dbo];

