CREATE TABLE [dbo].[tblPoTransLotRcpt] (
    [TransId]       [dbo].[pTransID]    NOT NULL,
    [EntryNum]      INT                 CONSTRAINT [DF_tblPoTransLotRcpt_EntryNum] DEFAULT ((0)) NOT NULL,
    [RcptNum]       [dbo].[pInvoiceNum] NOT NULL,
    [LotNum]        [dbo].[pLotNum]     NULL,
    [QtyOrder]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__QtyOr__09592FF1] DEFAULT (0) NULL,
    [QtyFilled]     [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__QtyFi__0A4D542A] DEFAULT (0) NULL,
    [UnitCost]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__UnitC__0B417863] DEFAULT (0) NULL,
    [UnitCostFgn]   [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__UnitC__0C359C9C] DEFAULT (0) NULL,
    [ExtCost]       [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__ExtCo__0D29C0D5] DEFAULT (0) NULL,
    [ExtCostFgn]    [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__ExtCo__0E1DE50E] DEFAULT (0) NULL,
    [HistSeqNum]    INT                 CONSTRAINT [DF__tblPoTran__HistS__0F120947] DEFAULT (0) NULL,
    [LotCmnt]       VARCHAR (35)        NULL,
    [Status]        TINYINT             CONSTRAINT [DF__tblPoTran__Statu__10062D80] DEFAULT (0) NULL,
    [QtySeqNum]     INT                 CONSTRAINT [DF_tblPoTransLotRcpt_QtySeqNum] DEFAULT (0) NULL,
    [ts]            ROWVERSION          NULL,
    [ReceiptID]     UNIQUEIDENTIFIER    CONSTRAINT [DF_tblPoTransLotRcpt_ReceiptID] DEFAULT (newid()) NOT NULL,
    [QtyAccRev]     [dbo].[pDec]        CONSTRAINT [DF_tblPoTransLotRcpt_QtyAccRev] DEFAULT ((0)) NULL,
    [AccAdjCostFgn] [dbo].[pDec]        CONSTRAINT [DF_tblPoTransLotRcpt_AccAdjCostFgn] DEFAULT ((0)) NULL,
    [AccAdjCost]    [dbo].[pDec]        CONSTRAINT [DF_tblPoTransLotRcpt_AccAdjCost] DEFAULT ((0)) NULL,
    [CF]            XML                 NULL,
    [ActivityId]    INT                 NULL,
    [ExtLocA]       INT                 NULL,
    [ExtLocB]       INT                 NULL,
    [QtySeqNum_Ext] INT                 CONSTRAINT [DF_tblPoTransLotRcpt_QtySeqNum_Ext] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_tblPoTransLotRcpt] PRIMARY KEY CLUSTERED ([ReceiptID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransLotRcpt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransLotRcpt';

