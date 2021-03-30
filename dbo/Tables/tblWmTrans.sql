CREATE TABLE [dbo].[tblWmTrans] (
    [TransId]       INT              NOT NULL,
    [BatchId]       [dbo].[pBatchID] DEFAULT ('######') NOT NULL,
    [TransType]     TINYINT          NOT NULL,
    [ItemId]        [dbo].[pItemID]  NULL,
    [LocId]         [dbo].[pLocID]   NULL,
    [LotNum]        [dbo].[pLotNum]  NULL,
    [ExtLocA]       INT              NULL,
    [ExtLocAID]     VARCHAR (10)     NULL,
    [ExtLocB]       INT              NULL,
    [ExtLocBID]     VARCHAR (10)     NULL,
    [Qty]           [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [Uom]           [dbo].[pUom]     NULL,
    [ConvFactor]    [dbo].[pDec]     CONSTRAINT [DF__tblWmTran__ConvF__7937D6C1] DEFAULT ((1)) NOT NULL,
    [UnitCost]      [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [EntryDate]     DATETIME         DEFAULT (getdate()) NULL,
    [TransDate]     DATETIME         DEFAULT (getdate()) NULL,
    [GLPeriod]      SMALLINT         DEFAULT ((0)) NOT NULL,
    [GlYear]        SMALLINT         DEFAULT ((0)) NOT NULL,
    [GLAcctOffset]  [dbo].[pGlAcct]  NULL,
    [HistSeqNum]    INT              NOT NULL,
    [LotHistSeqNum] INT              NOT NULL,
    [QtySeqNum]     INT              DEFAULT ((0)) NOT NULL,
    [QtySeqNumExt]  INT              DEFAULT ((0)) NOT NULL,
    [Cmnt]          VARCHAR (35)     NULL,
    [ts]            ROWVERSION       NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK__tblWmTrans] PRIMARY KEY CLUSTERED ([TransId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlBatchId]
    ON [dbo].[tblWmTrans]([BatchId] ASC, [TransId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmTrans_TransType]
    ON [dbo].[tblWmTrans]([TransType] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmTrans';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmTrans';

