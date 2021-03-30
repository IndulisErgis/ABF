CREATE TABLE [dbo].[tblInTransLot] (
    [TransId]     INT             NOT NULL,
    [SeqNum]      INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]      [dbo].[pItemID] NULL,
    [LocId]       [dbo].[pLocID]  NULL,
    [LotNum]      [dbo].[pLotNum] NULL,
    [QtyOrder]    [dbo].[pDec]    CONSTRAINT [DF__tblInTran__QtyOr__2E35AEE5] DEFAULT (0) NULL,
    [QtyFilled]   [dbo].[pDec]    CONSTRAINT [DF__tblInTran__QtyFi__2F29D31E] DEFAULT (0) NULL,
    [QtyBkord]    [dbo].[pDec]    CONSTRAINT [DF__tblInTran__QtyBk__301DF757] DEFAULT (0) NULL,
    [CostUnit]    [dbo].[pDec]    CONSTRAINT [DF__tblInTran__CostU__31121B90] DEFAULT (0) NULL,
    [CostUnitFgn] [dbo].[pDec]    CONSTRAINT [DF__tblInTran__CostU__32063FC9] DEFAULT (0) NULL,
    [HistSeqNum]  INT             NULL,
    [Cmnt]        VARCHAR (35)    NULL,
    [QtySeqNum]   INT             CONSTRAINT [DF_tblInTransLot_QtySeqNum] DEFAULT (0) NULL,
    [ts]          ROWVERSION      NULL,
    [CF]          XML             NULL,
    CONSTRAINT [PK__tblInTransLot__37C5420D] PRIMARY KEY CLUSTERED ([TransId] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInTransLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInTransLot';

