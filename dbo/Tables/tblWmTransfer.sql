CREATE TABLE [dbo].[tblWmTransfer] (
    [TranKey]         INT              IDENTITY (1, 1) NOT NULL,
    [BatchID]         [dbo].[pBatchID] NOT NULL,
    [Status]          TINYINT          DEFAULT ((0)) NOT NULL,
    [ItemId]          [dbo].[pItemID]  NULL,
    [LocId]           [dbo].[pLocID]   NULL,
    [LocIdTo]         [dbo].[pLocID]   NULL,
    [LotNum]          [dbo].[pLotNum]  NULL,
    [Qty]             [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [UOM]             [dbo].[pUom]     NOT NULL,
    [CostTransfer]    [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [EntryDate]       DATETIME         NOT NULL,
    [TransDate]       DATETIME         NOT NULL,
    [PackNum]         [dbo].[pTransID] NULL,
    [Cmnt]            TEXT             NULL,
    [ts]              ROWVERSION       NULL,
    [CF]              XML              NULL,
    [QtySeqNum_OnOrd] INT              NULL,
    [QtySeqNum_Cmtd]  INT              NULL,
    CONSTRAINT [PK__tblWmTransfer] PRIMARY KEY CLUSTERED ([TranKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmTransfer_BatchId]
    ON [dbo].[tblWmTransfer]([BatchID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmTransfer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmTransfer';

