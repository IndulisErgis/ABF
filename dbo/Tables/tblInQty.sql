CREATE TABLE [dbo].[tblInQty] (
    [SeqNum]        INT          IDENTITY (1, 1) NOT NULL,
    [ItemId]        CHAR (24)    NOT NULL,
    [LocId]         CHAR (10)    NOT NULL,
    [LotNum]        CHAR (16)    NULL,
    [TransType]     TINYINT      NOT NULL,
    [Qty]           [dbo].[pDec] CONSTRAINT [DF_tblInQty_Qty] DEFAULT (0) NOT NULL,
    [LinkID]        CHAR (2)     NOT NULL,
    [LinkIDSub]     CHAR (8)     NOT NULL,
    [LinkIDSubLine] CHAR (8)     NULL,
    CONSTRAINT [PK_tblInQty] PRIMARY KEY NONCLUSTERED ([SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQty_TransType]
    ON [dbo].[tblInQty]([TransType] ASC)
    INCLUDE([ItemId], [LocId], [Qty]);


GO
CREATE NONCLUSTERED INDEX [ix_tblINQty_LinkIDSub]
    ON [dbo].[tblInQty]([TransType] ASC, [LinkID] ASC)
    INCLUDE([ItemId], [LocId], [Qty], [LinkIDSub], [LinkIDSubLine]);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQty_ItemIdLocIdTransType]
    ON [dbo].[tblInQty]([ItemId] ASC, [LocId] ASC, [TransType] ASC)
    INCLUDE([Qty]);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblInQty] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInQty] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblInQty] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblInQty] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQty';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQty';

