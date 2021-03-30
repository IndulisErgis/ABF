CREATE TABLE [dbo].[tblPcProjectDetailSiteInfo] (
    [ProjectDetailID] INT              NOT NULL,
    [SiteID]          [dbo].[pLocID]   NULL,
    [Name]            NVARCHAR (30)    NULL,
    [Attention]       NVARCHAR (30)    NULL,
    [Address1]        NVARCHAR (30)    NULL,
    [Address2]        NVARCHAR (60)    NULL,
    [City]            NVARCHAR (30)    NULL,
    [Region]          NVARCHAR (10)    NULL,
    [Country]         [dbo].[pCountry] NULL,
    [PostalCode]      NVARCHAR (10)    NULL,
    [Phone]           NVARCHAR (15)    NULL,
    [Fax]             NVARCHAR (15)    NULL,
    [Email]           NVARCHAR (255)   NULL,
    [Internet]        NVARCHAR (255)   NULL,
    [CF]              XML              NULL,
    [ts]              ROWVERSION       NULL,
    CONSTRAINT [PK_tblPcProjectDetailSiteInfo] PRIMARY KEY CLUSTERED ([ProjectDetailID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcProjectDetailSiteInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcProjectDetailSiteInfo';

