CREATE TABLE [dbo].[tblInQty_Ext] (
    [ExtSeqNum] INT          IDENTITY (1, 1) NOT NULL,
    [SeqNum]    INT          NOT NULL,
    [ItemId]    CHAR (24)    NOT NULL,
    [LocId]     CHAR (10)    NOT NULL,
    [LotNum]    CHAR (16)    NULL,
    [ExtLocA]   INT          NULL,
    [ExtLocB]   INT          NULL,
    [TransType] TINYINT      NOT NULL,
    [Qty]       [dbo].[pDec] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblInQty_Ext] PRIMARY KEY CLUSTERED ([ExtSeqNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQty_Ext_ExtLocB]
    ON [dbo].[tblInQty_Ext]([ExtLocB] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQty_Ext_ExtLocA]
    ON [dbo].[tblInQty_Ext]([ExtLocA] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQty_Ext_ItemIdLocIdLotNum]
    ON [dbo].[tblInQty_Ext]([ItemId] ASC, [LocId] ASC, [LotNum] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQty_Ext_SeqNum]
    ON [dbo].[tblInQty_Ext]([SeqNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQty_Ext';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQty_Ext';

