CREATE TABLE [dbo].[tblCMContact] (
    [ContactRef]    INT              IDENTITY (1, 1) NOT NULL,
    [LinkId]        NVARCHAR (255)   NULL,
    [LinkType]      SMALLINT         CONSTRAINT [DF_tblCmContact_LinkType] DEFAULT ((0)) NOT NULL,
    [StatusRef]     INT              NULL,
    [ContactName]   NVARCHAR (30)    NULL,
    [Addr1]         VARCHAR (30)     NULL,
    [Addr2]         VARCHAR (60)     NULL,
    [City]          VARCHAR (30)     NULL,
    [Region]        VARCHAR (10)     NULL,
    [Country]       [dbo].[pCountry] NULL,
    [PostalCode]    VARCHAR (10)     NULL,
    [Notes]         NVARCHAR (MAX)   NULL,
    [ts]            ROWVERSION       NULL,
    [CF]            XML              NULL,
    [ReportToID]    BIGINT           NULL,
    [Status]        TINYINT          CONSTRAINT [DF_tblCmContact_Status] DEFAULT ((0)) NOT NULL,
    [LastUpdated]   DATETIME         NOT NULL,
    [LastUpdatedBy] [dbo].[pUserID]  NOT NULL,
    [Title]         NVARCHAR (30)    NULL,
    [FName]         NVARCHAR (30)    NULL,
    [MName]         NVARCHAR (30)    NULL,
    [LName]         NVARCHAR (30)    NULL,
    [Type]          SMALLINT         CONSTRAINT [DF_tblCmContact_Type] DEFAULT ((0)) NOT NULL,
    [StatusID]      BIGINT           NULL,
    [ID]            BIGINT           NOT NULL,
    CONSTRAINT [PK_tblCmContact] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCmContact_IDStatus]
    ON [dbo].[tblCMContact]([ID] ASC, [Status] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ContactName]
    ON [dbo].[tblCMContact]([ContactName] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMContact';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblCMContact';

