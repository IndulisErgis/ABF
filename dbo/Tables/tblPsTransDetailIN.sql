CREATE TABLE [dbo].[tblPsTransDetailIN] (
    [DetailID]       BIGINT           NOT NULL,
    [EntryDate]      DATETIME         NOT NULL,
    [ExtCost]        [dbo].[pDecimal] NOT NULL,
    [QtySeqNum_Cmtd] INT              NULL,
    [QtySeqNum]      INT              NULL,
    [HistSeqNum]     INT              NULL,
    [HistSeqNumSer]  INT              NULL,
    [CF]             XML              NULL,
    [ts]             ROWVERSION       NULL,
    CONSTRAINT [PK_tblPsTransDetailIN] PRIMARY KEY CLUSTERED ([DetailID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTransDetailIN';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTransDetailIN';

