CREATE TABLE [dbo].[tblSvEquipment] (
    [ID]                    BIGINT               NOT NULL,
    [GeneralEquipmentID]    BIGINT               NULL,
    [EquipmentNo]           NVARCHAR (24)        NOT NULL,
    [Description]           [dbo].[pDescription] NULL,
    [ItemID]                [dbo].[pItemID]      NULL,
    [SerialNumber]          [dbo].[pSerNum]      NULL,
    [TagNumber]             NVARCHAR (255)       NULL,
    [SiteYN]                BIT                  DEFAULT ((0)) NOT NULL,
    [CustID]                [dbo].[pCustID]      NULL,
    [SiteID]                [dbo].[pLocID]       NULL,
    [Manufacturer]          [dbo].[pDescription] NULL,
    [Model]                 [dbo].[pDescription] NULL,
    [CategoryID]            NVARCHAR (12)        NULL,
    [Status]                TINYINT              DEFAULT ((0)) NOT NULL,
    [Usage]                 TINYINT              DEFAULT ((0)) NOT NULL,
    [ServiceContractCharge] [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [Ownership]             TINYINT              DEFAULT ((0)) NOT NULL,
    [AssetID]               [dbo].[pAssetID]     NULL,
    [GLAcctExpense]         [dbo].[pGlAcct]      NULL,
    [AdditionalDescription] NVARCHAR (MAX)       NULL,
    [CF]                    XML                  NULL,
    [ts]                    ROWVERSION           NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvEquipment';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvEquipment';

