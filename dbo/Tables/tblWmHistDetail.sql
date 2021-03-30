CREATE TABLE [dbo].[tblWmHistDetail] (
    [ExtHistSeqNum] INT                 IDENTITY (1, 1) NOT NULL,
    [HistSeqNum]    INT                 NULL,
    [HistSeqNumLot] INT                 NULL,
    [HistSeqNumSer] INT                 NULL,
    [ItemId]        [dbo].[pItemID]     NULL,
    [LocId]         [dbo].[pLocID]      NULL,
    [Lotnum]        [dbo].[pLotNum]     NULL,
    [Sernum]        [dbo].[pSerNum]     NULL,
    [ExtLocA]       INT                 NULL,
    [ExtLocB]       INT                 NULL,
    [Source]        TINYINT             DEFAULT ((0)) NOT NULL,
    [TransId]       [dbo].[pTransID]    NULL,
    [EntryNum]      INT                 NULL,
    [ReceiptNum]    [dbo].[pInvoiceNum] NULL,
    [TransKey]      INT                 NULL,
    [TransDate]     DATETIME            DEFAULT (getdate()) NULL,
    [Qty]           [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [DeletedYn]     BIT                 DEFAULT ((0)) NOT NULL,
    [UID]           [dbo].[pUserID]     NOT NULL,
    [HostId]        [dbo].[pWrkStnID]   NOT NULL,
    [CF]            XML                 NULL,
    [EntryDate]     DATETIME            CONSTRAINT [DF_tblWmHistDetail_EntryDate] DEFAULT (getdate()) NOT NULL,
    [ExtLocAID]     VARCHAR (10)        NULL,
    [ExtLocBID]     VARCHAR (10)        NULL,
    [ReferenceId]   [dbo].[pInvoiceNum] NULL,
    CONSTRAINT [PK__tblWmHistDetail] PRIMARY KEY CLUSTERED ([ExtHistSeqNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmHistDetail_HistSeqNumSer]
    ON [dbo].[tblWmHistDetail]([HistSeqNumSer] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmHistDetail_HistSeqNum]
    ON [dbo].[tblWmHistDetail]([HistSeqNum] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlSerNum]
    ON [dbo].[tblWmHistDetail]([Sernum] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlLotNum]
    ON [dbo].[tblWmHistDetail]([Lotnum] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlLocId]
    ON [dbo].[tblWmHistDetail]([LocId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlItemId]
    ON [dbo].[tblWmHistDetail]([ItemId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistDetail';

