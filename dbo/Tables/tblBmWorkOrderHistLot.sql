CREATE TABLE [dbo].[tblBmWorkOrderHistLot] (
    [PostRun]     [dbo].[pPostRun] CONSTRAINT [DF__tblBmWork__PostR__07420643] DEFAULT (0) NOT NULL,
    [TransId]     [dbo].[pTransID] NOT NULL,
    [EntryNum]    INT              CONSTRAINT [DF__tblBmWork__Entry__08362A7C] DEFAULT (0) NOT NULL,
    [SeqNum]      INT              NOT NULL,
    [ItemId]      [dbo].[pItemID]  NOT NULL,
    [LocId]       [dbo].[pLocID]   NOT NULL,
    [LotNum]      [dbo].[pLotNum]  NOT NULL,
    [QtyOrder]    [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__QtyOr__092A4EB5] DEFAULT (0) NULL,
    [QtyFilled]   [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__QtyFi__0A1E72EE] DEFAULT (0) NULL,
    [QtyBkord]    [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__QtyBk__0B129727] DEFAULT (0) NULL,
    [CostUnit]    [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__CostU__0C06BB60] DEFAULT (0) NULL,
    [CostUnitFgn] [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__CostU__0CFADF99] DEFAULT (0) NULL,
    [HistSeqNum]  INT              CONSTRAINT [DF__tblBmWork__HistS__0DEF03D2] DEFAULT (0) NULL,
    [Cmnt]        VARCHAR (35)     NULL,
    [QtySeqNum]   INT              CONSTRAINT [DF__tblBmWork__QtySe__0EE3280B] DEFAULT (0) NULL,
    [ts]          ROWVERSION       NULL,
    [CF]          XML              NULL,
    CONSTRAINT [PK__tblBmWorkOrderHistLot] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [EntryNum] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderHistLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderHistLot';

