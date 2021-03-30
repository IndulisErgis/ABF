CREATE TABLE [dbo].[tblInQtyOnHand_Ext_Temp] (
    [PostRun]   [dbo].[pPostRun] NOT NULL,
    [ExtSeqNum] INT              NOT NULL,
    [ItemId]    NCHAR (24)       NOT NULL,
    [LocId]     NCHAR (10)       NOT NULL,
    [LotNum]    NCHAR (16)       NULL,
    [ExtLocA]   INT              NULL,
    [ExtLocB]   INT              NULL,
    [Qty]       [dbo].[pDec]     NOT NULL,
    CONSTRAINT [PK_tblInQtyOnHand_Ext_Temp] PRIMARY KEY CLUSTERED ([PostRun] ASC, [ExtSeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand_Ext_Temp';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand_Ext_Temp';

