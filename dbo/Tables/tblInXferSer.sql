CREATE TABLE [dbo].[tblInXferSer] (
    [HistSeqNumTo]  INT             NULL,
    [TransId]       INT             NOT NULL,
    [SeqNum]        INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]        [dbo].[pItemID] NULL,
    [LocId]         [dbo].[pLocID]  NULL,
    [LotNumFrom]    [dbo].[pLotNum] NULL,
    [LotNumTo]      [dbo].[pLotNum] NULL,
    [SerNum]        [dbo].[pSerNum] NULL,
    [CostUnit]      [dbo].[pDec]    CONSTRAINT [DF__tblInXfer__CostU__4F96A2B0] DEFAULT (0) NULL,
    [CostXfer]      [dbo].[pDec]    CONSTRAINT [DF__tblInXfer__CostX__508AC6E9] DEFAULT (0) NULL,
    [PriceUnit]     [dbo].[pDec]    CONSTRAINT [DF__tblInXfer__Price__517EEB22] DEFAULT (0) NULL,
    [HistSeqNum]    INT             NULL,
    [Cmnt]          VARCHAR (35)    NULL,
    [QtySeqNumFrom] INT             CONSTRAINT [DF_tblInXferSer_QtySeqNumFrom] DEFAULT (0) NULL,
    [QtySeqNumTo]   INT             CONSTRAINT [DF_tblInXferSer_QtySeqNumTo] DEFAULT (0) NULL,
    [ts]            ROWVERSION      NULL,
    [CF]            XML             NULL,
    [ExtLocAFrom]   INT             NULL,
    [ExtLocBFrom]   INT             NULL,
    [ExtLocATo]     INT             NULL,
    [ExtLocBTo]     INT             NULL,
    CONSTRAINT [PK__tblInXferSer__3D7E1B63] PRIMARY KEY CLUSTERED ([TransId] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInXferSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInXferSer';

