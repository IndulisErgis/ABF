CREATE TABLE [dbo].[tblInQtyOnHand_Offset_Temp] (
    [PostRun]       [dbo].[pPostRun] NOT NULL,
    [SeqNum]        INT              NOT NULL,
    [GrpID]         INT              NULL,
    [EntryDate]     DATETIME         NOT NULL,
    [Source]        TINYINT          NOT NULL,
    [Qty]           [dbo].[pDec]     NOT NULL,
    [Cost]          [dbo].[pDec]     NOT NULL,
    [OnHandLink]    INT              NOT NULL,
    [LinkID]        NCHAR (8)        NOT NULL,
    [LinkIDSub]     NCHAR (8)        NOT NULL,
    [LinkIDSubLine] INT              NULL,
    [CostActual]    [dbo].[pDec]     NOT NULL,
    [CostAdj]       [dbo].[pDec]     NOT NULL,
    [CostAdjPosted] [dbo].[pDec]     NOT NULL,
    [PostedYn]      BIT              NOT NULL,
    [DeletedYn]     BIT              NOT NULL,
    CONSTRAINT [PK_tblInQtyOnHand_Offset_Temp] PRIMARY KEY CLUSTERED ([PostRun] ASC, [SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand_Offset_Temp';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInQtyOnHand_Offset_Temp';

