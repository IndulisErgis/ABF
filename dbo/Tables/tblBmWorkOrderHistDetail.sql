CREATE TABLE [dbo].[tblBmWorkOrderHistDetail] (
    [PostRun]    [dbo].[pPostRun] CONSTRAINT [DF__tblBmWork__PostR__7CC477D0] DEFAULT (0) NOT NULL,
    [TransId]    [dbo].[pTransID] NOT NULL,
    [EntryNum]   INT              CONSTRAINT [DF_tblBmWorkOrderHistDetail_EntryNum] DEFAULT ((0)) NOT NULL,
    [ItemId]     [dbo].[pItemID]  NOT NULL,
    [LocId]      [dbo].[pLocID]   NOT NULL,
    [ItemType]   TINYINT          NULL,
    [OriCompQty] [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__OriCo__7EACC042] DEFAULT (0) NULL,
    [EstQty]     [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__EstQt__7FA0E47B] DEFAULT (0) NULL,
    [ActQty]     [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__ActQt__009508B4] DEFAULT (0) NULL,
    [Uom]        [dbo].[pUom]     NULL,
    [ConvFactor] [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__ConvF__01892CED] DEFAULT (1) NULL,
    [UnitCost]   [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__UnitC__027D5126] DEFAULT (0) NULL,
    [QtySeqNum]  INT              CONSTRAINT [DF__tblBmWork__QtySe__0371755F] DEFAULT (0) NULL,
    [HistSeqNum] INT              CONSTRAINT [DF__tblBmWork__HistS__04659998] DEFAULT (0) NULL,
    [ts]         ROWVERSION       NULL,
    [CF]         XML              NULL,
    CONSTRAINT [PK_tblBmWorkOrderHistDetail] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [EntryNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderHistDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderHistDetail';

