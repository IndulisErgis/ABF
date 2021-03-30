CREATE TABLE [dbo].[tblMpHistoryMatlDtlExt] (
    [PostRun]       [dbo].[pPostRun]     NOT NULL,
    [TransId]       INT                  NOT NULL,
    [EntryNum]      INT                  NOT NULL,
    [SeqNum]        INT                  NOT NULL,
    [LotNum]        [dbo].[pLotNum]      NULL,
    [ExtLocAID]     NVARCHAR (10)        NULL,
    [ExtLocBID]     NVARCHAR (10)        NULL,
    [QtyFilled]     [dbo].[pDec]         CONSTRAINT [DF_tblMpHistoryMatlDtlExt_QtyFilled] DEFAULT ((0)) NOT NULL,
    [CostUnit]      [dbo].[pDec]         CONSTRAINT [DF_tblMpHistoryMatlDtlExt_CostUnit] DEFAULT ((0)) NOT NULL,
    [CostUnitFgn]   [dbo].[pDec]         CONSTRAINT [DF_tblMpHistoryMatlDtlExt_CostUnitFgn] DEFAULT ((0)) NOT NULL,
    [HistSeqNum]    INT                  NULL,
    [HistSeqNumExt] INT                  NULL,
    [QtySeqNum]     INT                  NULL,
    [QtySeqNumExt]  INT                  NULL,
    [Cmnt]          [dbo].[pDescription] NULL,
    [CF]            XML                  NULL,
    [ts]            ROWVERSION           NULL,
    CONSTRAINT [PK_tblMpHistoryMatlDtlExt] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [EntryNum] ASC, [SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryMatlDtlExt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryMatlDtlExt';

