CREATE TABLE [dbo].[tblBmKitHistDetail] (
    [Counter]    INT             IDENTITY (1, 1) NOT NULL,
    [HistSeqNum] INT             NULL,
    [EntryNum]   INT             NULL,
    [ItemId]     [dbo].[pItemID] NULL,
    [LocId]      [dbo].[pLocID]  NULL,
    [ItemType]   TINYINT         CONSTRAINT [DF__tblBmKitH__ItemT__6557CDEA] DEFAULT (0) NOT NULL,
    [LottedYN]   BIT             CONSTRAINT [DF__tblBmKitH__Lotte__664BF223] DEFAULT (0) NOT NULL,
    [Uom]        [dbo].[pUom]    NULL,
    [ConvFactor] [dbo].[pDec]    CONSTRAINT [DF__tblBmKitH__ConvF__6740165C] DEFAULT (1) NOT NULL,
    [Qty]        [dbo].[pDec]    CONSTRAINT [DF__tblBmKitHis__Qty__68343A95] DEFAULT (0) NOT NULL,
    [UnitCost]   [dbo].[pDec]    CONSTRAINT [DF_tblBmKitHistDetail_UnitCost] DEFAULT (0) NOT NULL,
    [UnitPrice]  [dbo].[pDec]    CONSTRAINT [DF_tblBmKitHistDetail_UnitPrice] DEFAULT (0) NOT NULL,
    [ts]         ROWVERSION      NULL,
    [CF]         XML             NULL,
    CONSTRAINT [PK__tblBmKitHistDeta__513BC6A4] PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlLocId]
    ON [dbo].[tblBmKitHistDetail]([LocId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlItemId]
    ON [dbo].[tblBmKitHistDetail]([ItemId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlHistSeqNum]
    ON [dbo].[tblBmKitHistDetail]([HistSeqNum] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlEntryNum]
    ON [dbo].[tblBmKitHistDetail]([EntryNum] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmKitHistDetail] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmKitHistDetail] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmKitHistDetail] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmKitHistDetail] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmKitHistDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmKitHistDetail';

