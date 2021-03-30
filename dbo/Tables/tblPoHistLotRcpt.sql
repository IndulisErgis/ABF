CREATE TABLE [dbo].[tblPoHistLotRcpt] (
    [PostRun]       [dbo].[pPostRun]    NOT NULL,
    [TransId]       [dbo].[pTransID]    NOT NULL,
    [EntryNum]      INT                 NOT NULL,
    [RcptNum]       [dbo].[pInvoiceNum] NOT NULL,
    [LotNum]        [dbo].[pLotNum]     NULL,
    [QtyOrder]      [dbo].[pDec]        NULL,
    [QtyFilled]     [dbo].[pDec]        NULL,
    [UnitCost]      [dbo].[pDec]        NULL,
    [UnitCostFgn]   [dbo].[pDec]        NULL,
    [ExtCost]       [dbo].[pDec]        NULL,
    [ExtCostFgn]    [dbo].[pDec]        NULL,
    [HistSeqNum]    INT                 NULL,
    [LotCmnt]       VARCHAR (35)        NULL,
    [Status]        TINYINT             NULL,
    [ts]            ROWVERSION          NULL,
    [QtySeqNum]     INT                 NULL,
    [ReceiptID]     UNIQUEIDENTIFIER    CONSTRAINT [DF_tblPoHistLotRcpt_ReceiptID] DEFAULT (newid()) NOT NULL,
    [QtyAccRev]     [dbo].[pDec]        NULL,
    [AccAdjCostFgn] [dbo].[pDec]        NULL,
    [AccAdjCost]    [dbo].[pDec]        NULL,
    [CF]            XML                 NULL,
    [ActivityId]    INT                 NULL,
    [ExtLocAID]     VARCHAR (10)        NULL,
    [ExtLocBID]     VARCHAR (10)        NULL,
    [QtySeqNum_Ext] INT                 NULL
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPoHistLotRcpt] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPoHistLotRcpt] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPoHistLotRcpt] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPoHistLotRcpt] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistLotRcpt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistLotRcpt';

