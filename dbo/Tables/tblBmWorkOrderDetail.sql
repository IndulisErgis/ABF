CREATE TABLE [dbo].[tblBmWorkOrderDetail] (
    [TransId]    [dbo].[pTransID] NOT NULL,
    [EntryNum]   INT              CONSTRAINT [DF_tblBmWorkOrderDetail_EntryNum] DEFAULT ((0)) NOT NULL,
    [ItemId]     [dbo].[pItemID]  NOT NULL,
    [LocId]      [dbo].[pLocID]   NOT NULL,
    [ItemType]   TINYINT          NULL,
    [OriCompQty] [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__OriCo__529933DA] DEFAULT (0) NULL,
    [EstQty]     [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__EstQt__538D5813] DEFAULT (0) NULL,
    [ActQty]     [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__ActQt__54817C4C] DEFAULT (0) NULL,
    [Uom]        [dbo].[pUom]     NULL,
    [ConvFactor] [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__ConvF__5575A085] DEFAULT (1) NULL,
    [UnitCost]   [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__UnitC__5669C4BE] DEFAULT (0) NULL,
    [QtySeqNum]  INT              CONSTRAINT [DF__tblBmWork__QtySe__575DE8F7] DEFAULT (0) NULL,
    [HistSeqNum] INT              CONSTRAINT [DF__tblBmWork__HistS__58520D30] DEFAULT (0) NULL,
    [ts]         ROWVERSION       NULL,
    [CF]         XML              NULL,
    CONSTRAINT [PK_tblBmWorkOrderDetail] PRIMARY KEY CLUSTERED ([TransId] ASC, [EntryNum] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmWorkOrderDetail] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmWorkOrderDetail] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmWorkOrderDetail] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmWorkOrderDetail] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderDetail';

