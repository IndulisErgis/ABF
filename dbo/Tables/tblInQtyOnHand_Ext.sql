CREATE TABLE [dbo].[tblInQtyOnHand_Ext] (
    [ExtSeqNum] INT          IDENTITY (1, 1) NOT NULL,
    [ItemId]    CHAR (24)    NOT NULL,
    [LocId]     CHAR (10)    NOT NULL,
    [LotNum]    CHAR (16)    NULL,
    [ExtLocA]   INT          NULL,
    [ExtLocB]   INT          NULL,
    [Qty]       [dbo].[pDec] NOT NULL,
    CONSTRAINT [PK_tblInQtyOnHand_Ext] PRIMARY KEY CLUSTERED ([ExtSeqNum] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQtyOnHand_Ext_ExtLocB]
    ON [dbo].[tblInQtyOnHand_Ext]([ExtLocB] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQtyOnHand_Ext_ExtLocA]
    ON [dbo].[tblInQtyOnHand_Ext]([ExtLocA] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQtyOnHand_Ext]
    ON [dbo].[tblInQtyOnHand_Ext]([ItemId] ASC, [LocId] ASC, [LotNum] ASC) WITH (FILLFACTOR = 90);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand_Ext';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand_Ext';

