CREATE TABLE [dbo].[tblWmRcpt] (
    [RcptKey]    INT                 IDENTITY (1, 1) NOT NULL,
    [TransId]    [dbo].[pTransID]    NULL,
    [EntryNum]   INT                 NULL,
    [ReceiptNum] [dbo].[pInvoiceNum] NOT NULL,
    [ItemId]     [dbo].[pItemID]     NOT NULL,
    [LocId]      [dbo].[pLocID]      NOT NULL,
    [SerNum]     [dbo].[pSerNum]     NULL,
    [LotNum]     [dbo].[pLotNum]     NULL,
    [ExtLocA]    INT                 NULL,
    [ExtLocAID]  VARCHAR (10)        NULL,
    [ExtLocB]    INT                 NULL,
    [ExtLocBID]  VARCHAR (10)        NULL,
    [UOM]        [dbo].[pUom]        NOT NULL,
    [Qty]        [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [Source]     TINYINT             DEFAULT ((0)) NOT NULL,
    [ErrorFlag]  TINYINT             DEFAULT ((0)) NOT NULL,
    [UID]        [dbo].[pUserID]     NULL,
    [HostId]     [dbo].[pWrkStnID]   NULL,
    [EntryDate]  DATETIME            NOT NULL,
    [TransDate]  DATETIME            NOT NULL,
    [ts]         ROWVERSION          NULL,
    [CF]         XML                 NULL,
    [Status]     TINYINT             NOT NULL,
    CONSTRAINT [PK__tblWmRcpt] PRIMARY KEY CLUSTERED ([RcptKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmRcpt_UIDWrkStnId]
    ON [dbo].[tblWmRcpt]([UID] ASC, [HostId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmRcpt_TransIdEntryNumRcptId]
    ON [dbo].[tblWmRcpt]([TransId] ASC, [EntryNum] ASC, [ReceiptNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmRcpt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmRcpt';

