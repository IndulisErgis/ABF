CREATE TABLE [dbo].[tblInItemLocLot_New] (
    [ItemId]      [dbo].[pItemID]   NOT NULL,
    [LocId]       [dbo].[pLocID]    NOT NULL,
    [LotNum]      [dbo].[pLotNum]   NOT NULL,
    [LotStatus]   TINYINT           NULL,
    [InitialDate] DATETIME          NULL,
    [ExpDate]     DATETIME          NULL,
    [VendID]      [dbo].[pVendorID] NULL,
    [Cmnt]        VARCHAR (35)      NULL,
    [ts]          ROWVERSION        NULL,
    [CF]          XML               NULL,
    PRIMARY KEY CLUSTERED ([ItemId] ASC, [LocId] ASC, [LotNum] ASC) WITH (FILLFACTOR = 80)
);

