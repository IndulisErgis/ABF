CREATE TABLE [dbo].[tblMpMatlDtlExt] (
    [TransId]       INT                  NOT NULL,
    [EntryNum]      INT                  NOT NULL,
    [SeqNum]        INT                  IDENTITY (1, 1) NOT NULL,
    [LotNum]        [dbo].[pLotNum]      NULL,
    [ExtLocA]       INT                  NULL,
    [ExtLocB]       INT                  NULL,
    [QtyFilled]     [dbo].[pDec]         CONSTRAINT [DF_tblMpMatlDtlExt_QtyFilled] DEFAULT ((0)) NOT NULL,
    [CostUnit]      [dbo].[pDec]         CONSTRAINT [DF_tblMpMatlDtlExt_CostUnit] DEFAULT ((0)) NOT NULL,
    [HistSeqNum]    INT                  NULL,
    [HistSeqNumExt] INT                  NULL,
    [QtySeqNum]     INT                  NULL,
    [QtySeqNumExt]  INT                  NULL,
    [Cmnt]          [dbo].[pDescription] NULL,
    [CF]            XML                  NULL,
    [ts]            ROWVERSION           NULL,
    CONSTRAINT [PK_tblMpMatlDtlExt] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblMpMatlDtlExt_TransIdEntryNum]
    ON [dbo].[tblMpMatlDtlExt]([TransId] ASC, [EntryNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpMatlDtlExt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpMatlDtlExt';

