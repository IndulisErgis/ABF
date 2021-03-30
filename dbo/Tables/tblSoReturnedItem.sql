CREATE TABLE [dbo].[tblSoReturnedItem] (
    [Counter]       INT                 IDENTITY (1, 1) NOT NULL,
    [Status]        TINYINT             DEFAULT ((1)) NULL,
    [ResCode]       VARCHAR (10)        NULL,
    [RMANumber]     [dbo].[pInvoiceNum] NULL,
    [CustID]        [dbo].[pCustID]     NULL,
    [TransId]       [dbo].[pTransID]    NULL,
    [EntryNum]      INT                 NULL,
    [ItemId]        [dbo].[pItemID]     NULL,
    [LocId]         [dbo].[pLocID]      NULL,
    [ExtLocA]       INT                 NULL,
    [ExtLocAID]     VARCHAR (10)        NULL,
    [ExtLocB]       INT                 NULL,
    [ExtLocBID]     VARCHAR (10)        NULL,
    [EntryDate]     DATETIME            NULL,
    [TransDate]     DATETIME            NULL,
    [Units]         [dbo].[pUom]        NULL,
    [QtyReturn]     [dbo].[pDec]        DEFAULT ((0)) NULL,
    [LotNum]        [dbo].[pLotNum]     NULL,
    [SerNum]        [dbo].[pSerNum]     NULL,
    [UnitCost]      [dbo].[pDec]        DEFAULT ((0)) NULL,
    [CostExt]       [dbo].[pDec]        DEFAULT ((0)) NULL,
    [UnitPrice]     [dbo].[pDec]        DEFAULT ((0)) NULL,
    [PriceExt]      [dbo].[pDec]        DEFAULT ((0)) NULL,
    [QtySeqNum]     INT                 DEFAULT ((0)) NOT NULL,
    [QtySeqNumExt]  INT                 DEFAULT ((0)) NOT NULL,
    [GLAcctCOGS]    [dbo].[pGlAcct]     NULL,
    [GLAcctInv]     [dbo].[pGlAcct]     NULL,
    [Notes]         TEXT                NULL,
    [ts]            ROWVERSION          NULL,
    [HistSeqNum]    INT                 CONSTRAINT [DF_tblSoReturnedItem_HistSeqNum] DEFAULT ((0)) NOT NULL,
    [HistSeqNumSer] INT                 CONSTRAINT [DF_tblSoReturnedItem_HistSeqNumSer] DEFAULT ((0)) NOT NULL,
    [CF]            XML                 NULL,
    CONSTRAINT [PK__tblSoReturnedItem] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSoReturnedItem_Status]
    ON [dbo].[tblSoReturnedItem]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblSoReturnedItem_TransIdEntryNum]
    ON [dbo].[tblSoReturnedItem]([TransId] ASC, [EntryNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoReturnedItem';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoReturnedItem';

