CREATE TABLE [dbo].[tblMpMatlSer] (
    [TransId]      INT             NOT NULL,
    [EntryNum]     INT             CONSTRAINT [DF__tblMpMatlSer_EntryNum] DEFAULT ((0)) NOT NULL,
    [SeqNum]       INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]       [dbo].[pItemID] NOT NULL,
    [LocId]        [dbo].[pLocID]  NOT NULL,
    [LotNum]       [dbo].[pLotNum] NULL,
    [SerNum]       [dbo].[pSerNum] NOT NULL,
    [CostUnit]     [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [CostUnitFgn]  [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [PriceUnit]    [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [PriceUnitFgn] [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [HistSeqNum]   INT             DEFAULT ((0)) NOT NULL,
    [Cmnt]         VARCHAR (35)    NULL,
    [QtySeqNum]    INT             DEFAULT ((0)) NOT NULL,
    [ts]           ROWVERSION      NULL,
    [CF]           XML             NULL,
    [ExtLocA]      INT             NULL,
    [ExtLocB]      INT             NULL,
    CONSTRAINT [PK_tblMpMatlSer] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpMatlSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpMatlSer';

