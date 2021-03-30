CREATE TABLE [dbo].[tblApTransLot] (
    [TransId]     [dbo].[pTransID] NOT NULL,
    [EntryNum]    INT              NOT NULL,
    [SeqNum]      INT              IDENTITY (1, 1) NOT NULL,
    [ItemId]      [dbo].[pItemID]  NULL,
    [LocId]       [dbo].[pLocID]   NULL,
    [LotNum]      [dbo].[pLotNum]  NULL,
    [QtyOrder]    [dbo].[pDec]     CONSTRAINT [DF__tblApTran__QtyOr__67633F49] DEFAULT (0) NULL,
    [QtyFilled]   [dbo].[pDec]     CONSTRAINT [DF__tblApTran__QtyFi__68576382] DEFAULT (0) NULL,
    [QtyBkord]    [dbo].[pDec]     CONSTRAINT [DF__tblApTran__QtyBk__694B87BB] DEFAULT (0) NULL,
    [CostUnit]    [dbo].[pDec]     CONSTRAINT [DF__tblApTran__CostU__6A3FABF4] DEFAULT (0) NULL,
    [CostUnitFgn] [dbo].[pDec]     CONSTRAINT [DF__tblApTran__CostU__6B33D02D] DEFAULT (0) NULL,
    [HistSeqNum]  INT              NULL,
    [Cmnt]        VARCHAR (35)     NULL,
    [QtySeqNum]   INT              CONSTRAINT [DF_tblApTransLot_QtySeqNum] DEFAULT (0) NULL,
    [ts]          ROWVERSION       NULL,
    [CF]          XML              NULL,
    CONSTRAINT [PK_tblApTransLot] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransLot';

