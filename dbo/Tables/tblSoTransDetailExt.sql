CREATE TABLE [dbo].[tblSoTransDetailExt] (
    [TransId]        [dbo].[pTransID] NOT NULL,
    [EntryNum]       INT              NOT NULL,
    [SeqNum]         INT              IDENTITY (1, 1) NOT NULL,
    [LotNum]         [dbo].[pLotNum]  NULL,
    [ExtLocA]        INT              NULL,
    [ExtLocB]        INT              NULL,
    [QtyOrder]       [dbo].[pDec]     CONSTRAINT [DF_tblSoTransDetailExt_QtyOrder] DEFAULT ((0)) NOT NULL,
    [QtyFilled]      [dbo].[pDec]     CONSTRAINT [DF_tblSoTransDetailExt_QtyFilled] DEFAULT ((0)) NOT NULL,
    [CostUnit]       [dbo].[pDec]     CONSTRAINT [DF_tblSoTransDetailExt_CostUnit] DEFAULT ((0)) NOT NULL,
    [CostUnitFgn]    [dbo].[pDec]     CONSTRAINT [DF_tblSoTransDetailExt_CostUnitFgn] DEFAULT ((0)) NOT NULL,
    [HistSeqNum]     INT              CONSTRAINT [DF_tblSoTransDetailExt_HistSeqNum] DEFAULT ((0)) NULL,
    [QtySeqNum_Cmtd] INT              NULL,
    [QtySeqNum]      INT              NULL,
    [QtySeqNum_Ext]  INT              NULL,
    [Cmnt]           VARCHAR (35)     NULL,
    [CF]             XML              NULL,
    [ts]             ROWVERSION       NULL,
    CONSTRAINT [PK_tblSoTransDetailExt] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSoTransDetailExt_TransId]
    ON [dbo].[tblSoTransDetailExt]([TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransDetailExt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransDetailExt';

