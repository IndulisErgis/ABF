CREATE TABLE [dbo].[tblSvEquipmentWarranty] (
    [ID]              INT                  IDENTITY (1, 1) NOT NULL,
    [EquipmentID]     BIGINT               NOT NULL,
    [CoverageType]    TINYINT              DEFAULT ((0)) NOT NULL,
    [IntervalType]    TINYINT              DEFAULT ((0)) NOT NULL,
    [Interval]        TINYINT              DEFAULT ((0)) NOT NULL,
    [StartDate]       DATETIME             NULL,
    [EndDate]         DATETIME             NULL,
    [CF]              XML                  NULL,
    [ts]              ROWVERSION           NULL,
    [Descr]           [dbo].[pDescription] NULL,
    [BillingTypeDflt] NVARCHAR (10)        NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvEquipmentWarranty';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvEquipmentWarranty';

