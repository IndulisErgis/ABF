CREATE TABLE [dbo].[tblDRRunItemLoc] (
    [RunId]     [dbo].[pPostRun] NOT NULL,
    [ItemId]    [dbo].[pItemID]  NOT NULL,
    [LocId]     [dbo].[pLocID]   NOT NULL,
    [QtyOnHand] [dbo].[pDec]     CONSTRAINT [DF_tblDrRunItemLoc_QtyOnHand] DEFAULT ((0)) NOT NULL,
    [CF]        XML              NULL,
    [ts]        ROWVERSION       NULL,
    CONSTRAINT [PK_tblDrRunItemLoc] PRIMARY KEY CLUSTERED ([RunId] ASC, [ItemId] ASC, [LocId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDRRunItemLoc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblDRRunItemLoc';

