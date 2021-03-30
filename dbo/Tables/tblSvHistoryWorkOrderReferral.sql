CREATE TABLE [dbo].[tblSvHistoryWorkOrderReferral] (
    [ID]          BIGINT           NOT NULL,
    [CustID]      [dbo].[pCustID]  NULL,
    [CompanyName] NVARCHAR (30)    NULL,
    [ContactName] NVARCHAR (30)    NULL,
    [Address1]    NVARCHAR (30)    NULL,
    [Address2]    NVARCHAR (60)    NULL,
    [City]        NVARCHAR (30)    NULL,
    [Region]      NVARCHAR (10)    NULL,
    [Country]     [dbo].[pCountry] NULL,
    [PostalCode]  NVARCHAR (10)    NULL,
    [Phone]       NVARCHAR (15)    NULL,
    [Fax]         NVARCHAR (15)    NULL,
    [Email]       NVARCHAR (255)   NULL,
    [Internet]    NVARCHAR (255)   NULL,
    [Notes]       NVARCHAR (MAX)   NULL,
    [CF]          XML              NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderReferral';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvHistoryWorkOrderReferral';

