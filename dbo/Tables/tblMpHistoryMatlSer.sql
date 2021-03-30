CREATE TABLE [dbo].[tblMpHistoryMatlSer] (
    [PostRun]      [dbo].[pPostRun] NOT NULL,
    [TransId]      INT              NOT NULL,
    [EntryNum]     SMALLINT         DEFAULT ((0)) NOT NULL,
    [SeqNum]       INT              CONSTRAINT [DF__tmp_rg_xx__SeqNu__5E44B4BA] DEFAULT ((0)) NOT NULL,
    [ItemId]       [dbo].[pItemID]  NOT NULL,
    [LocId]        [dbo].[pLocID]   NOT NULL,
    [LotNum]       [dbo].[pLotNum]  NULL,
    [SerNum]       [dbo].[pSerNum]  NOT NULL,
    [CostUnit]     [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [CostUnitFgn]  [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [PriceUnit]    [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [PriceUnitFgn] [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [HistSeqNum]   INT              DEFAULT ((0)) NOT NULL,
    [Cmnt]         VARCHAR (35)     NULL,
    [QtySeqNum]    INT              DEFAULT ((0)) NOT NULL,
    [ts]           ROWVERSION       NULL,
    [CF]           XML              NULL,
    [ExtLocAID]    VARCHAR (10)     NULL,
    [ExtLocBID]    VARCHAR (10)     NULL,
    CONSTRAINT [PK_tblMpHistoryMatlSer] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [EntryNum] ASC, [SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryMatlSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryMatlSer';

