CREATE TABLE [dbo].[tblEpHCEmployeeProviderInfo] (
    [ID]         BIGINT           NOT NULL,
    [HeaderId]   BIGINT           NOT NULL,
    [EIN]        NVARCHAR (255)   NULL,
    [Name1]      NVARCHAR (30)    NULL,
    [Name2]      NVARCHAR (30)    NULL,
    [Address1]   NVARCHAR (30)    NULL,
    [Address2]   NVARCHAR (60)    NULL,
    [City]       NVARCHAR (30)    NULL,
    [Region]     NVARCHAR (10)    NULL,
    [Country]    [dbo].[pCountry] NULL,
    [PostalCode] NVARCHAR (10)    NULL,
    [Phone]      NVARCHAR (15)    NULL,
    [PhoneExt]   NVARCHAR (15)    NULL,
    [CF]         XML              NULL,
    [ts]         ROWVERSION       NULL,
    CONSTRAINT [PK_tblEpHCEmployeeProviderInfo] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployeeProviderInfo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblEpHCEmployeeProviderInfo';

