CREATE TABLE [dbo].[tblInItemLocLot] (
    [ItemId]      [dbo].[pItemID]   NOT NULL,
    [LocId]       [dbo].[pLocID]    NOT NULL,
    [LotNum]      [dbo].[pLotNum]   NOT NULL,
    [LotStatus]   TINYINT           CONSTRAINT [DF__tblInItem__LotSt__31CF9EF1] DEFAULT (1) NULL,
    [InitialDate] DATETIME          NULL,
    [ExpDate]     DATETIME          NULL,
    [VendID]      [dbo].[pVendorID] NULL,
    [Cmnt]        VARCHAR (35)      NULL,
    [ts]          ROWVERSION        NULL,
    [CF]          XML               NULL,
    PRIMARY KEY CLUSTERED ([ItemId] ASC, [LocId] ASC, [LotNum] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemLocLot] TO [WebUserRole]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblInItemLocLot] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemLocLot] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblInItemLocLot] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblInItemLocLot] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemLocLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemLocLot';

