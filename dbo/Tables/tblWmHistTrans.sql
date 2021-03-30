CREATE TABLE [dbo].[tblWmHistTrans] (
    [ID]           BIGINT           IDENTITY (1, 1) NOT NULL,
    [PostRun]      [dbo].[pPostRun] NOT NULL,
    [TransID]      INT              NOT NULL,
    [BatchID]      [dbo].[pBatchID] NOT NULL,
    [TransType]    TINYINT          NOT NULL,
    [ItemID]       [dbo].[pItemID]  NOT NULL,
    [LocID]        [dbo].[pLocID]   NOT NULL,
    [LotNum]       [dbo].[pLotNum]  NULL,
    [ExtLocA]      INT              NULL,
    [ExtLocB]      INT              NULL,
    [ExtLocAID]    NVARCHAR (10)    NULL,
    [ExtLocBID]    NVARCHAR (10)    NULL,
    [Qty]          [dbo].[pDecimal] NOT NULL,
    [QtyBase]      [dbo].[pDecimal] NOT NULL,
    [UOM]          [dbo].[pUom]     NOT NULL,
    [UOMBase]      [dbo].[pUom]     NOT NULL,
    [CostUnit]     [dbo].[pDecimal] NOT NULL,
    [CostExt]      [dbo].[pDecimal] NOT NULL,
    [EntryDate]    DATETIME         NOT NULL,
    [TransDate]    DATETIME         NOT NULL,
    [FiscalPeriod] SMALLINT         NOT NULL,
    [FiscalYear]   SMALLINT         NOT NULL,
    [GLAcctOffset] [dbo].[pGlAcct]  NOT NULL,
    [GLAcctInvAdj] [dbo].[pGlAcct]  NOT NULL,
    [HistSeqNum]   INT              NOT NULL,
    [QtySeqNum]    INT              NOT NULL,
    [QtySeqNumExt] INT              NOT NULL,
    [Cmnt]         NVARCHAR (35)    NULL,
    [CF]           XML              NULL,
    CONSTRAINT [PK_tblWmHistTrans] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblWmHistTrans_PostRunTransID]
    ON [dbo].[tblWmHistTrans]([PostRun] ASC, [TransID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistTrans';

