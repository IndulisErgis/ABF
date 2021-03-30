CREATE TABLE [dbo].[tblInMatReqSer] (
    [TransId]     INT             NOT NULL,
    [LineNum]     SMALLINT        NOT NULL,
    [SeqNum]      INT             IDENTITY (1, 1) NOT NULL,
    [LotNum]      [dbo].[pLotNum] NULL,
    [SerNum]      [dbo].[pSerNum] NULL,
    [CostUnit]    [dbo].[pDec]    CONSTRAINT [DF__tblInMatR__CostU__4DE36468] DEFAULT (0) NULL,
    [CostUnitFgn] [dbo].[pDec]    CONSTRAINT [DF__tblInMatR__CostU__4ED788A1] DEFAULT (0) NULL,
    [HistSeqNum]  INT             NULL,
    [Cmnt]        VARCHAR (35)    NULL,
    [QtySeqNum]   INT             CONSTRAINT [DF_tblInMatReqSer_QtySeqNum] DEFAULT (0) NULL,
    [ts]          ROWVERSION      NULL,
    [CF]          XML             NULL,
    [ExtLocA]     INT             NULL,
    [ExtLocB]     INT             NULL,
    CONSTRAINT [PK__tblInMatReqSer__297722B6] PRIMARY KEY CLUSTERED ([TransId] ASC, [LineNum] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInMatReqSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInMatReqSer';

