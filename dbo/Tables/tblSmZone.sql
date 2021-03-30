CREATE TABLE [dbo].[tblSmZone] (
    [ID]          BIGINT               NOT NULL,
    [ZoneCode]    NVARCHAR (10)        NOT NULL,
    [Description] [dbo].[pDescription] NULL,
    [ZoneType]    TINYINT              CONSTRAINT [DF_tblSmZone_ZoneType] DEFAULT ((0)) NOT NULL,
    [Contact]     NVARCHAR (30)        NULL,
    [Address1]    NVARCHAR (30)        NULL,
    [Address2]    NVARCHAR (60)        NULL,
    [City]        NVARCHAR (30)        NULL,
    [Region]      NVARCHAR (10)        NULL,
    [Country]     [dbo].[pCountry]     NULL,
    [PostalCode]  NVARCHAR (10)        NULL,
    [Phone]       NVARCHAR (20)        NULL,
    [Fax]         NVARCHAR (20)        NULL,
    [Email]       [dbo].[pEmail]       NULL,
    [CF]          XML                  NULL,
    [ts]          ROWVERSION           NULL,
    CONSTRAINT [PK_tblSmZone] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblSmZone_ZoneCode]
    ON [dbo].[tblSmZone]([ZoneCode] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmZone';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmZone';

