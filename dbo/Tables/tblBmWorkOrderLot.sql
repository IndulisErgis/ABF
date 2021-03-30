CREATE TABLE [dbo].[tblBmWorkOrderLot] (
    [TransId]     [dbo].[pTransID] NOT NULL,
    [EntryNum]    INT              CONSTRAINT [DF__tblBmWork__Entry__5B2E79DB] DEFAULT (0) NOT NULL,
    [SeqNum]      INT              IDENTITY (1, 1) NOT NULL,
    [ItemId]      [dbo].[pItemID]  NOT NULL,
    [LocId]       [dbo].[pLocID]   NOT NULL,
    [LotNum]      [dbo].[pLotNum]  NOT NULL,
    [QtyOrder]    [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__QtyOr__5C229E14] DEFAULT (0) NULL,
    [QtyFilled]   [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__QtyFi__5D16C24D] DEFAULT (0) NULL,
    [QtyBkord]    [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__QtyBk__5E0AE686] DEFAULT (0) NULL,
    [CostUnit]    [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__CostU__5EFF0ABF] DEFAULT (0) NULL,
    [CostUnitFgn] [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__CostU__5FF32EF8] DEFAULT (0) NULL,
    [HistSeqNum]  INT              CONSTRAINT [DF__tblBmWork__HistS__60E75331] DEFAULT (0) NULL,
    [Cmnt]        VARCHAR (35)     NULL,
    [QtySeqNum]   INT              CONSTRAINT [DF__tblBmWork__QtySe__61DB776A] DEFAULT (0) NULL,
    [ts]          ROWVERSION       NULL,
    [CF]          XML              NULL,
    CONSTRAINT [PK__tblBmWorkOrderLot] PRIMARY KEY CLUSTERED ([TransId] ASC, [EntryNum] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmWorkOrderLot] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmWorkOrderLot] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmWorkOrderLot] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmWorkOrderLot] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderLot';

