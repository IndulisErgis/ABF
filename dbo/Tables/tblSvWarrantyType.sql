CREATE TABLE [dbo].[tblSvWarrantyType] (
    [WarrantyType] NVARCHAR (10)        NOT NULL,
    [Descr]        [dbo].[pDescription] NULL,
    [CoverageType] TINYINT              CONSTRAINT [DF_tblSvWarrantyType_CoverageType] DEFAULT ((0)) NOT NULL,
    [BillingType]  NVARCHAR (10)        NULL,
    [CF]           XML                  NULL,
    [ts]           ROWVERSION           NULL,
    CONSTRAINT [PK_tblSvWarrantyType] PRIMARY KEY CLUSTERED ([WarrantyType] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWarrantyType';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvWarrantyType';

