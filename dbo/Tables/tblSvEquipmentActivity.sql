CREATE TABLE [dbo].[tblSvEquipmentActivity] (
    [ID]            INT                  IDENTITY (1, 1) NOT NULL,
    [EquipmentID]   BIGINT               NOT NULL,
    [Type]          TINYINT              NOT NULL,
    [Description]   [dbo].[pDescription] NULL,
    [ContactID]     NVARCHAR (10)        NULL,
    [SiteID]        [dbo].[pLocID]       NULL,
    [ContactName]   NVARCHAR (30)        NULL,
    [Address1]      NVARCHAR (30)        NULL,
    [Address2]      NVARCHAR (60)        NULL,
    [City]          NVARCHAR (30)        NULL,
    [Region]        NVARCHAR (10)        NULL,
    [Country]       [dbo].[pCountry]     NULL,
    [PostalCode]    NVARCHAR (10)        NULL,
    [Phone]         NVARCHAR (15)        NULL,
    [Fax]           NVARCHAR (15)        NULL,
    [OrderDate]     DATETIME             NULL,
    [ShipDate]      DATETIME             NULL,
    [InvoiceDate]   DATETIME             NULL,
    [OrderNumber]   NVARCHAR (25)        NULL,
    [InvoiceNumber] [dbo].[pInvoiceNum]  NULL,
    [Price]         [dbo].[pDec]         NULL,
    [CF]            XML                  NULL,
    [ts]            ROWVERSION           NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvEquipmentActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvEquipmentActivity';

