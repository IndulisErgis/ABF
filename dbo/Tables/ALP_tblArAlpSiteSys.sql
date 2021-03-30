CREATE TABLE [dbo].[ALP_tblArAlpSiteSys] (
    [SysId]          INT           IDENTITY (1, 1) NOT NULL,
    [CustId]         VARCHAR (10)  NULL,
    [SiteId]         INT           NOT NULL,
    [InstallDate]    DATETIME      NULL,
    [ContractId]     INT           NULL,
    [SysTypeId]      INT           NOT NULL,
    [SysDesc]        VARCHAR (255) NULL,
    [CentralId]      INT           NULL,
    [AlarmId]        VARCHAR (50)  NULL,
    [WarrPlanId]     INT           NULL,
    [WarrTerm]       SMALLINT      NULL,
    [WarrExpires]    DATETIME      NULL,
    [RepPlanId]      INT           NULL,
    [LeaseYN]        BIT           CONSTRAINT [DF_ALP_tblArAlpSiteSys_LeaseYN] DEFAULT ((0)) NOT NULL,
    [PulledDate]     DATETIME      NULL,
    [CreateDate]     DATETIME      NULL,
    [LastUpdateDate] DATETIME      NULL,
    [UploadDate]     DATETIME      NULL,
    [ts]             ROWVERSION    NULL,
    [ModifiedBy]     VARCHAR (50)  NULL,
    [ModifiedDate]   DATETIME      NULL,
    CONSTRAINT [PK_tblArAlpSiteSys] PRIMARY KEY CLUSTERED ([SysId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_tblArAlpSiteSys_tblArAlpSite] FOREIGN KEY ([SiteId]) REFERENCES [dbo].[ALP_tblArAlpSite] ([SiteId]) NOT FOR REPLICATION,
    CONSTRAINT [IX_tblArAlpSiteSys] UNIQUE NONCLUSTERED ([SysTypeId] ASC, [SysDesc] ASC, [SiteId] ASC, [CustId] ASC) WITH (FILLFACTOR = 80)
);


GO
ALTER TABLE [dbo].[ALP_tblArAlpSiteSys] NOCHECK CONSTRAINT [FK_tblArAlpSiteSys_tblArAlpSite];


GO
CREATE NONCLUSTERED INDEX [IX_ALP_tblArAlpSiteSys_SiteId]
    ON [dbo].[ALP_tblArAlpSiteSys]([SiteId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ALP_tblArAlpSiteSys_CustIdSiteId]
    ON [dbo].[ALP_tblArAlpSiteSys]([CustId] ASC, [SiteId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ALP_tblArAlpSiteSys_CustID]
    ON [dbo].[ALP_tblArAlpSiteSys]([CustId] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteSys] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteSys] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteSys] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteSys] TO PUBLIC
    AS [dbo];

