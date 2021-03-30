CREATE TABLE [dbo].[tblWmHistTransfer] (
    [ID]              BIGINT           IDENTITY (1, 1) NOT NULL,
    [PostRun]         [dbo].[pPostRun] NOT NULL,
    [TranKey]         INT              NOT NULL,
    [BatchID]         [dbo].[pBatchID] NOT NULL,
    [ItemID]          [dbo].[pItemID]  NOT NULL,
    [LocID]           [dbo].[pLocID]   NOT NULL,
    [LocIDTo]         [dbo].[pLocID]   NOT NULL,
    [LotNum]          [dbo].[pLotNum]  NULL,
    [Qty]             [dbo].[pDecimal] NOT NULL,
    [QtyBase]         [dbo].[pDecimal] NOT NULL,
    [UOM]             [dbo].[pUom]     NOT NULL,
    [UOMBase]         [dbo].[pUom]     NOT NULL,
    [CostTransfer]    [dbo].[pDecimal] NOT NULL,
    [GLAcctXferCost]  [dbo].[pGlAcct]  NULL,
    [GLAcctInTransit] [dbo].[pGlAcct]  NOT NULL,
    [GLAcctInvAdj]    [dbo].[pGlAcct]  NOT NULL,
    [GLAcctInvFrom]   [dbo].[pGlAcct]  NOT NULL,
    [GLAcctInvTo]     [dbo].[pGlAcct]  NOT NULL,
    [EntryDate]       DATETIME         NOT NULL,
    [TransDate]       DATETIME         NOT NULL,
    [PackNum]         [dbo].[pTransID] NULL,
    [QtySeqNum_OnOrd] INT              NULL,
    [QtySeqNum_Cmtd]  INT              NULL,
    [Cmnt]            NVARCHAR (MAX)   NULL,
    [CF]              XML              NULL,
    CONSTRAINT [PK_tblWmHistTransfer] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblWmHistTransfer_PostRunTranKey]
    ON [dbo].[tblWmHistTransfer]([PostRun] ASC, [TranKey] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistTransfer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistTransfer';

