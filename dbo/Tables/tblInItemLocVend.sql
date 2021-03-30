CREATE TABLE [dbo].[tblInItemLocVend] (
    [ItemId]           [dbo].[pItemID]   NOT NULL,
    [LocId]            [dbo].[pLocID]    NOT NULL,
    [VendId]           [dbo].[pVendorID] NOT NULL,
    [VendName]         VARCHAR (30)      NULL,
    [VendItemId]       [dbo].[pItemID]   NULL,
    [LastPOUnitCost]   [dbo].[pDec]      CONSTRAINT [DF__tblInItem__LastP__12C29E9A] DEFAULT (0) NOT NULL,
    [LastPODate]       DATETIME          NULL,
    [LastPOQty]        [dbo].[pDec]      CONSTRAINT [DF__tblInItem__LastP__13B6C2D3] DEFAULT (0) NOT NULL,
    [LastPOConvFactor] [dbo].[pDec]      CONSTRAINT [DF__tblInItem__LastP__14AAE70C] DEFAULT (1) NOT NULL,
    [LastPOOrderNum]   VARCHAR (25)      NULL,
    [LastPOUom]        [dbo].[pUom]      NULL,
    [LeadTime]         [dbo].[pDec]      CONSTRAINT [DF__tblInItem__LeadT__159F0B45] DEFAULT (0) NOT NULL,
    [BrkId]            VARCHAR (10)      NULL,
    [ts]               ROWVERSION        NULL,
    [CurrencyID]       [dbo].[pCurrency] NULL,
    [ExchRate]         [dbo].[pDec]      CONSTRAINT [DF__tblInItemLocVend__ExchRate] DEFAULT ((1)) NOT NULL,
    [LandedCostID]     VARCHAR (10)      NULL,
    [CF]               XML               NULL,
    CONSTRAINT [PK__tblInItemLocVend__1E05700A] PRIMARY KEY CLUSTERED ([ItemId] ASC, [LocId] ASC, [VendId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemLocVend';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemLocVend';

