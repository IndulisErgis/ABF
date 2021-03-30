CREATE TABLE [dbo].[tblInMatReqLot] (
    [TransId]     INT             NOT NULL,
    [LineNum]     SMALLINT        NOT NULL,
    [SeqNum]      INT             IDENTITY (1, 1) NOT NULL,
    [LotNum]      [dbo].[pLotNum] NULL,
    [QtyOrder]    [dbo].[pDec]    CONSTRAINT [DF__tblInMatR__QtyOr__473666D9] DEFAULT (0) NULL,
    [QtyFilled]   [dbo].[pDec]    CONSTRAINT [DF__tblInMatR__QtyFi__482A8B12] DEFAULT (0) NULL,
    [QtyBkord]    [dbo].[pDec]    CONSTRAINT [DF__tblInMatR__QtyBk__491EAF4B] DEFAULT (0) NULL,
    [CostUnit]    [dbo].[pDec]    CONSTRAINT [DF__tblInMatR__CostU__4A12D384] DEFAULT (0) NULL,
    [CostUnitFgn] [dbo].[pDec]    CONSTRAINT [DF__tblInMatR__CostU__4B06F7BD] DEFAULT (0) NULL,
    [HistSeqNum]  INT             NULL,
    [Cmnt]        VARCHAR (35)    NULL,
    [QtySeqNum]   INT             CONSTRAINT [DF_tblInMatReqLot_QtySeqNum] DEFAULT (0) NULL,
    [ts]          ROWVERSION      NULL,
    [CF]          XML             NULL,
    CONSTRAINT [PK__tblInMatReqLot__2882FE7D] PRIMARY KEY CLUSTERED ([TransId] ASC, [LineNum] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInMatReqLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInMatReqLot';

