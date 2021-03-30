CREATE TABLE [dbo].[tblInQtyOnHand_Temp] (
    [PostRun]       [dbo].[pPostRun] NOT NULL,
    [SeqNum]        INT              NOT NULL,
    [EntryDate]     DATETIME         NOT NULL,
    [EntryID]       INT              NOT NULL,
    [ItemId]        NCHAR (24)       NOT NULL,
    [LocId]         NCHAR (10)       NOT NULL,
    [LotNum]        NCHAR (16)       NULL,
    [Source]        TINYINT          NOT NULL,
    [Qty]           [dbo].[pDec]     NOT NULL,
    [Cost]          [dbo].[pDec]     NOT NULL,
    [InvoicedQty]   [dbo].[pDec]     NOT NULL,
    [RcptLink]      INT              NULL,
    [RemoveQty]     [dbo].[pDec]     NOT NULL,
    [LinkID]        NCHAR (8)        NOT NULL,
    [LinkIDSub]     NCHAR (8)        NOT NULL,
    [LinkIDSubLine] INT              NULL,
    [PostedYn]      BIT              NOT NULL,
    [DeletedYn]     BIT              NOT NULL,
    CONSTRAINT [PK_tblInQtyOnHand_Temp] PRIMARY KEY CLUSTERED ([PostRun] ASC, [SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand_Temp';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand_Temp';

