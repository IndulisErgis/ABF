CREATE TABLE [dbo].[tblInQtyOnHand] (
    [SeqNum]        INT          IDENTITY (1, 1) NOT NULL,
    [EntryDate]     DATETIME     CONSTRAINT [DF_tblInQtyOnHand_EntryDate] DEFAULT (getdate()) NOT NULL,
    [EntryID]       INT          CONSTRAINT [DF_tblInQtyOnHand_EntryID] DEFAULT (0) NOT NULL,
    [ItemId]        CHAR (24)    NOT NULL,
    [LocId]         CHAR (10)    NOT NULL,
    [LotNum]        CHAR (16)    NULL,
    [Source]        TINYINT      CONSTRAINT [DF__tblInQtyOnHand__Source__6557CDEA] DEFAULT (0) NOT NULL,
    [Qty]           [dbo].[pDec] NOT NULL,
    [Cost]          [dbo].[pDec] NOT NULL,
    [InvoicedQty]   [dbo].[pDec] CONSTRAINT [DF_tblInQtyOnHand_InvoicedQty] DEFAULT (0) NOT NULL,
    [RcptLink]      INT          NULL,
    [RemoveQty]     [dbo].[pDec] CONSTRAINT [DF_tblInQtyOnHand_RemoveQty] DEFAULT (0) NOT NULL,
    [LinkID]        CHAR (8)     NOT NULL,
    [LinkIDSub]     CHAR (8)     NOT NULL,
    [LinkIDSubLine] INT          NULL,
    [PostedYn]      BIT          CONSTRAINT [DF__tblInQtyOnHand__PostedYn__6B10A740] DEFAULT (0) NOT NULL,
    [DeletedYn]     BIT          CONSTRAINT [DF_tblInQtyOnHand_DeletedYn] DEFAULT (0) NOT NULL,
    CONSTRAINT [PK_tblInQtyOnHand] PRIMARY KEY CLUSTERED ([SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQtyOnHand]
    ON [dbo].[tblInQtyOnHand]([ItemId] ASC, [LocId] ASC, [LotNum] ASC) WITH (FILLFACTOR = 80);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInQtyOnHand] TO [WebUserRole]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblInQtyOnHand] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInQtyOnHand] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblInQtyOnHand] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblInQtyOnHand] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand';

