CREATE TABLE [dbo].[tblSvEquipmentParts] (
    [ID]              INT                  IDENTITY (1, 1) NOT NULL,
    [EquipmentID]     BIGINT               NOT NULL,
    [PartNo]          NVARCHAR (24)        NOT NULL,
    [ItemID]          [dbo].[pItemID]      NULL,
    [Description]     [dbo].[pDescription] NULL,
    [Qty]             [dbo].[pDec]         NULL,
    [EstimatedCost]   [dbo].[pDec]         NULL,
    [PreferredVendor] [dbo].[pDescription] NULL,
    [LeadTime]        [dbo].[pDec]         NULL,
    [CF]              XML                  NULL,
    [ts]              ROWVERSION           NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvEquipmentParts';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvEquipmentParts';

