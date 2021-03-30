CREATE TABLE [dbo].[tblInQtyOnHand_Offset] (
    [SeqNum]        INT          IDENTITY (1, 1) NOT NULL,
    [GrpID]         INT          NULL,
    [EntryDate]     DATETIME     CONSTRAINT [DF_tblInQtyOnHand_Offset_EntryDate] DEFAULT (getdate()) NOT NULL,
    [Source]        TINYINT      CONSTRAINT [DF_tblInQtyOnHand_Offset_Source] DEFAULT (0) NOT NULL,
    [Qty]           [dbo].[pDec] NOT NULL,
    [Cost]          [dbo].[pDec] NOT NULL,
    [OnHandLink]    INT          NOT NULL,
    [LinkID]        CHAR (8)     NOT NULL,
    [LinkIDSub]     CHAR (8)     NOT NULL,
    [LinkIDSubLine] INT          NULL,
    [CostActual]    [dbo].[pDec] CONSTRAINT [DF_tblInQtyOnHand_Offset_CostActual] DEFAULT (0) NOT NULL,
    [CostAdj]       [dbo].[pDec] CONSTRAINT [DF_tblInQtyOnHand_Offset_CostAdj] DEFAULT (0) NOT NULL,
    [CostAdjPosted] [dbo].[pDec] CONSTRAINT [DF_tblInQtyOnHand_Offset_CostAdjPosted] DEFAULT (0) NOT NULL,
    [PostedYn]      BIT          CONSTRAINT [DF_tblInQtyOnHand_Offset_PostedYn] DEFAULT (0) NOT NULL,
    [DeletedYn]     BIT          CONSTRAINT [DF_tblInQtyOnHand_Offset_DeletedYn] DEFAULT (0) NOT NULL,
    CONSTRAINT [PK_tblInQtyOnHand_Offset] PRIMARY KEY CLUSTERED ([SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQtyOnHand_Offset_GrpId]
    ON [dbo].[tblInQtyOnHand_Offset]([GrpID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblInQtyOnHand_Offset]
    ON [dbo].[tblInQtyOnHand_Offset]([OnHandLink] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblInQtyOnHand_Offset] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInQtyOnHand_Offset] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblInQtyOnHand_Offset] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblInQtyOnHand_Offset] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand_Offset';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand_Offset';

