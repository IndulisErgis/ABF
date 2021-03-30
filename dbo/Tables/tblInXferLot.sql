CREATE TABLE [dbo].[tblInXferLot] (
    [HistSeqNumTo]  INT             NULL,
    [TransId]       INT             NOT NULL,
    [SeqNum]        INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]        [dbo].[pItemID] NULL,
    [LocId]         [dbo].[pLocID]  NULL,
    [LotNumFrom]    [dbo].[pLotNum] NULL,
    [LotNumTo]      [dbo].[pLotNum] NULL,
    [QtyOrder]      [dbo].[pDec]    CONSTRAINT [DF__tblInXfer__QtyOr__3C83CE3C] DEFAULT (0) NULL,
    [QtyFilled]     [dbo].[pDec]    CONSTRAINT [DF__tblInXfer__QtyFi__3D77F275] DEFAULT (0) NULL,
    [QtyBkord]      [dbo].[pDec]    CONSTRAINT [DF__tblInXfer__QtyBk__3E6C16AE] DEFAULT (0) NULL,
    [CostUnit]      [dbo].[pDec]    CONSTRAINT [DF__tblInXfer__CostU__3F603AE7] DEFAULT (0) NULL,
    [CostXfer]      [dbo].[pDec]    CONSTRAINT [DF__tblInXfer__CostX__40545F20] DEFAULT (0) NULL,
    [HistSeqNum]    INT             NULL,
    [Cmnt]          VARCHAR (35)    NULL,
    [QtySeqNumFrom] INT             CONSTRAINT [DF_tblInXferLot_QtySeqNumFrom] DEFAULT (0) NULL,
    [QtySeqNumTo]   INT             CONSTRAINT [DF_tblInXferLot_QtySeqNumTo] DEFAULT (0) NULL,
    [ts]            ROWVERSION      NULL,
    [CF]            XML             NULL,
    CONSTRAINT [PK__tblInXferLot__3B95D2F1] PRIMARY KEY CLUSTERED ([TransId] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInXferLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInXferLot';

