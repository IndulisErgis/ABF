CREATE TABLE [dbo].[ALP_tblArAlpSiteRecJob] (
    [RecJobEntryId]      INT          IDENTITY (1, 1) NOT NULL,
    [CreateDate]         DATETIME     NULL,
    [CustId]             VARCHAR (10) NULL,
    [SiteId]             INT          NULL,
    [RecBillEntryId]     INT          NULL,
    [RecSvcId]           INT          NULL,
    [SysId]              INT          NULL,
    [ContractId]         INT          NULL,
    [CustPoNum]          VARCHAR (25) NULL,
    [JobCycleId]         INT          NULL,
    [LastCycleStartDate] DATETIME     NULL,
    [NextCycleStartDate] DATETIME     NULL,
    [ExpirationDate]     DATETIME     NULL,
    [LastDateCreated]    DATETIME     NULL,
    [Contact]            VARCHAR (60) NULL,
    [ContactPhone]       VARCHAR (15) NULL,
    [WorkDesc]           TEXT         NULL,
    [WorkCodeId]         INT          NULL,
    [RepPlanId]          INT          NULL,
    [PriceId]            VARCHAR (15) NULL,
    [BranchId]           INT          NULL,
    [DeptId]             INT          NULL,
    [DivId]              INT          NULL,
    [SkillId]            INT          NULL,
    [PrefTechId]         INT          NULL,
    [EstHrs]             FLOAT (53)   NULL,
    [PrefTime]           VARCHAR (50) NULL,
    [OtherComments]      TEXT         NULL,
    [SalesRepId]         VARCHAR (3)  NULL,
    [ts]                 ROWVERSION   NULL,
    [ModifiedBy]         VARCHAR (50) NULL,
    [ModifiedDate]       DATETIME     NULL,
    [PhoneExt]           VARCHAR (10) NULL,
    CONSTRAINT [PK_tblJmRecJob] PRIMARY KEY CLUSTERED ([RecJobEntryId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_ALP_tblArAlpSiteRecJob_SysId]
    ON [dbo].[ALP_tblArAlpSiteRecJob]([SysId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ALP_tblArAlpSiteRecJob_SiteId]
    ON [dbo].[ALP_tblArAlpSiteRecJob]([SiteId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ALP_tblArAlpSiteRecJob_CustId]
    ON [dbo].[ALP_tblArAlpSiteRecJob]([CustId] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecJob] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecJob] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecJob] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteRecJob] TO PUBLIC
    AS [dbo];

