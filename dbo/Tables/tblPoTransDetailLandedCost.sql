CREATE TABLE [dbo].[tblPoTransDetailLandedCost] (
    [LCTransSeqNum] INT                  IDENTITY (1, 1) NOT NULL,
    [TransID]       [dbo].[pTransID]     NOT NULL,
    [EntryNum]      INT                  NOT NULL,
    [Description]   [dbo].[pDescription] NULL,
    [CostType]      TINYINT              NOT NULL,
    [Amount]        [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [Level]         TINYINT              NOT NULL,
    [CalcAmount]    [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [LCDtlSeqNum]   INT                  NOT NULL,
    [CF]            XML                  NULL,
    CONSTRAINT [PK_tblPoTransDetailLandedCost] PRIMARY KEY CLUSTERED ([LCTransSeqNum] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UI_tblPoTransDetailLandedCost_TransIDEntryNumLCTransSeqNum]
    ON [dbo].[tblPoTransDetailLandedCost]([TransID] ASC, [EntryNum] ASC, [LCTransSeqNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransDetailLandedCost';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransDetailLandedCost';

