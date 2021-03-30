CREATE TABLE [dbo].[tblInPhysCount] (
    [SeqNum]               INT              IDENTITY (1, 1) NOT NULL,
    [BatchId]              [dbo].[pBatchID] NULL,
    [ItemId]               [dbo].[pItemID]  NULL,
    [LocId]                [dbo].[pLocID]   NULL,
    [LotNum]               [dbo].[pLotNum]  NULL,
    [SerNum]               [dbo].[pSerNum]  NULL,
    [BinNum]               VARCHAR (10)     NULL,
    [DfltBinNum]           VARCHAR (10)     NULL,
    [ProductLine]          VARCHAR (12)     NULL,
    [UsrFld1]              VARCHAR (12)     NULL,
    [UsrFld2]              VARCHAR (12)     NULL,
    [QtyFrozen]            [dbo].[pDec]     CONSTRAINT [DF__tblInPhys__QtyFr__74FD3189] DEFAULT (0) NULL,
    [QtyCounted]           [dbo].[pDec]     CONSTRAINT [DF__tblInPhys__QtyCo__75F155C2] DEFAULT (0) NULL,
    [CountedUom]           [dbo].[pUom]     NULL,
    [CountedUomConvFactor] [dbo].[pDec]     CONSTRAINT [DF__tblInPhys__Count__76E579FB] DEFAULT (1) NULL,
    [TagNum]               INT              NULL,
    [VerifyYn]             BIT              CONSTRAINT [DF__tblInPhys__Verif__77D99E34] DEFAULT (0) NULL,
    [ts]                   ROWVERSION       NULL,
    [CostFrozen]           [dbo].[pDec]     CONSTRAINT [DF__tblInPhys__CostFrozen] DEFAULT ((0)) NULL,
    [ExtLocBID]            VARCHAR (10)     NULL,
    [CF]                   XML              NULL,
    [TotalQtyFrozen]       [dbo].[pDec]     CONSTRAINT [DF_tblInPhysCount_TotalQtyFrozen] DEFAULT ((0)) NOT NULL,
    [TotalQtyCounted]      [dbo].[pDec]     CONSTRAINT [DF_tblInPhysCount_TotalQtyCounted] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__tblInPhysCount__74090D50] PRIMARY KEY CLUSTERED ([SeqNum] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [UC_tblInPhysCount] UNIQUE NONCLUSTERED ([BatchId] ASC, [ItemId] ASC, [LocId] ASC, [LotNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlUsrFld2]
    ON [dbo].[tblInPhysCount]([UsrFld2] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlUsrFld1]
    ON [dbo].[tblInPhysCount]([UsrFld1] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlTagNum]
    ON [dbo].[tblInPhysCount]([TagNum] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlLotNum]
    ON [dbo].[tblInPhysCount]([LotNum] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlLocId]
    ON [dbo].[tblInPhysCount]([LocId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlItemId]
    ON [dbo].[tblInPhysCount]([ItemId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlBatchId]
    ON [dbo].[tblInPhysCount]([BatchId] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInPhysCount';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInPhysCount';

