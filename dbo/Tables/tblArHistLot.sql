CREATE TABLE [dbo].[tblArHistLot] (
    [PostRun]     [dbo].[pPostRun] CONSTRAINT [DF__tblArHist__PostR__641CBE4A] DEFAULT (0) NOT NULL,
    [TransId]     [dbo].[pTransID] NOT NULL,
    [EntryNum]    INT              NOT NULL,
    [SeqNum]      INT              CONSTRAINT [DF__tblArHist__SeqNu__660506BC] DEFAULT (0) NOT NULL,
    [ItemId]      [dbo].[pItemID]  NULL,
    [LocId]       [dbo].[pLocID]   NULL,
    [LotNum]      [dbo].[pLotNum]  NULL,
    [QtyOrder]    [dbo].[pDec]     CONSTRAINT [DF_tblArHistLot_QtyOrder] DEFAULT (0) NULL,
    [QtyFilled]   [dbo].[pDec]     CONSTRAINT [DF_tblArHistLot_QtyFilled] DEFAULT (0) NULL,
    [QtyBkord]    [dbo].[pDec]     CONSTRAINT [DF_tblArHistLot_QtyBkord] DEFAULT (0) NULL,
    [CostUnit]    [dbo].[pDec]     CONSTRAINT [DF_tblArHistLot_CostUnit] DEFAULT (0) NULL,
    [CostUnitFgn] [dbo].[pDec]     CONSTRAINT [DF_tblArHistLot_CostUnitFgn] DEFAULT (0) NULL,
    [HistSeqNum]  INT              NULL,
    [Cmnt]        VARCHAR (35)     NULL,
    [CF]          XML              NULL,
    CONSTRAINT [PK_tblArHistLot] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [EntryNum] ASC, [SeqNum] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblArHistLot] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArHistLot] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblArHistLot] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblArHistLot] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistLot';

