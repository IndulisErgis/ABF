CREATE TABLE [dbo].[tblArTransLot] (
    [TransId]     [dbo].[pTransID] NOT NULL,
    [EntryNum]    INT              NOT NULL,
    [SeqNum]      INT              IDENTITY (1, 1) NOT NULL,
    [ItemId]      [dbo].[pItemID]  NULL,
    [LocId]       [dbo].[pLocID]   NULL,
    [LotNum]      [dbo].[pLotNum]  NULL,
    [QtyOrder]    [dbo].[pDec]     CONSTRAINT [DF_tblArTransLot_QtyOrder] DEFAULT (0) NULL,
    [QtyFilled]   [dbo].[pDec]     CONSTRAINT [DF_tblArTransLot_QtyFilled] DEFAULT (0) NULL,
    [QtyBkord]    [dbo].[pDec]     CONSTRAINT [DF_tblArTransLot_QtyBkord] DEFAULT (0) NULL,
    [CostUnit]    [dbo].[pDec]     CONSTRAINT [DF_tblArTransLot_CostUnit] DEFAULT (0) NULL,
    [CostUnitFgn] [dbo].[pDec]     CONSTRAINT [DF_tblArTransLot_CostUnitFgn] DEFAULT (0) NULL,
    [HistSeqNum]  INT              NULL,
    [Cmnt]        VARCHAR (35)     NULL,
    [QtySeqNum]   INT              CONSTRAINT [DF_tblArTransLot_QtySeqNum] DEFAULT (0) NULL,
    [ts]          ROWVERSION       NULL,
    [CF]          XML              NULL,
    CONSTRAINT [PK_tblArTransLot] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArTransLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArTransLot';

