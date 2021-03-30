CREATE TABLE [dbo].[tblMpMatlSumExt] (
    [TransId]      INT                  NOT NULL,
    [SeqNum]       INT                  IDENTITY (1, 1) NOT NULL,
    [LotNum]       [dbo].[pLotNum]      NULL,
    [ExtLocA]      INT                  NULL,
    [ExtLocB]      INT                  NULL,
    [QtyRequired]  [dbo].[pDec]         CONSTRAINT [DF_tblMpMatlSumExt_QtyRequired] DEFAULT ((0)) NOT NULL,
    [QtyFilled]    [dbo].[pDec]         CONSTRAINT [DF_tblMpMatlSumExt_QtyFilled] DEFAULT ((0)) NOT NULL,
    [QtySeqNumExt] INT                  NULL,
    [Cmnt]         [dbo].[pDescription] NULL,
    [CF]           XML                  NULL,
    [ts]           ROWVERSION           NULL,
    CONSTRAINT [PK_tblMpMatlSumExt] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblMpMatlSumExt_TransId]
    ON [dbo].[tblMpMatlSumExt]([TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpMatlSumExt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpMatlSumExt';

