CREATE TABLE [dbo].[tblPoHistDetailLandedCost] (
    [PostRun]       [dbo].[pPostRun]     NOT NULL,
    [LCTransSeqNum] INT                  NOT NULL,
    [TransID]       [dbo].[pTransID]     NOT NULL,
    [EntryNum]      INT                  NOT NULL,
    [Description]   [dbo].[pDescription] NULL,
    [CostType]      TINYINT              NOT NULL,
    [Amount]        [dbo].[pDec]         NOT NULL,
    [Level]         TINYINT              NOT NULL,
    [CalcAmount]    [dbo].[pDec]         NOT NULL,
    [LCDtlSeqNum]   INT                  NOT NULL,
    [CF]            XML                  NULL,
    CONSTRAINT [PK_tblPoHistDetailLandedCost] PRIMARY KEY CLUSTERED ([PostRun] ASC, [LCTransSeqNum] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UI_tblPoHistDetailLandedCost_TransIDEntryNumLCTransSeqNum]
    ON [dbo].[tblPoHistDetailLandedCost]([TransID] ASC, [EntryNum] ASC, [PostRun] ASC, [LCTransSeqNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistDetailLandedCost';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistDetailLandedCost';

