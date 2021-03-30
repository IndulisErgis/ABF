CREATE TABLE [dbo].[tblBmKitHistLot] (
    [Counter]    INT             IDENTITY (1, 1) NOT NULL,
    [HistSeqNum] INT             NOT NULL,
    [EntryNum]   INT             NULL,
    [ItemId]     [dbo].[pItemID] NOT NULL,
    [LocId]      [dbo].[pLocID]  NOT NULL,
    [LotNum]     [dbo].[pLotNum] NOT NULL,
    [QtyTrans]   [dbo].[pDec]    CONSTRAINT [DF_tblBmKitHistLot_QtyTrans] DEFAULT (0) NOT NULL,
    [CostUnit]   [dbo].[pDec]    CONSTRAINT [DF_tblBmKitHistLot_CostUnit] DEFAULT (0) NOT NULL,
    [PriceUnit]  [dbo].[pDec]    CONSTRAINT [DF_tblBmKitHistLot_PriceUnit] DEFAULT (0) NOT NULL,
    [ts]         ROWVERSION      NULL,
    [CF]         XML             NULL,
    CONSTRAINT [PK__tblBmKitHistLot__50C5FA01] PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmKitHistLot] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmKitHistLot] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmKitHistLot] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmKitHistLot] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmKitHistLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmKitHistLot';

