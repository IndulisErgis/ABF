CREATE TABLE [dbo].[tblPoTransInvoice] (
    [TransID]     [dbo].[pTransID]    NOT NULL,
    [EntryNum]    INT                 CONSTRAINT [DF_tblPoTransInvoice_EntryNum] DEFAULT ((0)) NOT NULL,
    [InvoiceNum]  [dbo].[pInvoiceNum] NOT NULL,
    [Status]      TINYINT             CONSTRAINT [DF__tblPoTran__Statu__3B2595AF] DEFAULT (0) NULL,
    [Qty]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTransI__Qty__3EF62693] DEFAULT (0) NULL,
    [UnitCost]    [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__UnitC__3FEA4ACC] DEFAULT (0) NULL,
    [UnitCostFgn] [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__UnitC__40DE6F05] DEFAULT (0) NULL,
    [ExtCost]     [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__ExtCo__41D2933E] DEFAULT (0) NULL,
    [ExtCostFgn]  [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__ExtCo__42C6B777] DEFAULT (0) NULL,
    [HistSeqNum]  INT                 CONSTRAINT [DF__tblPoTran__HistS__43BADBB0] DEFAULT (0) NULL,
    [AvgRcptCost] [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__AvgRc__44AEFFE9] DEFAULT (0) NULL,
    [TransHistID] VARCHAR (10)        NULL,
    [QtySeqNum]   INT                 CONSTRAINT [DF_tblPoTransInvoice_QtySeqNum] DEFAULT (0) NULL,
    [ts]          ROWVERSION          NULL,
    [InvoiceID]   UNIQUEIDENTIFIER    DEFAULT (newid()) NOT NULL,
    [CF]          XML                 NULL
);


GO
CREATE NONCLUSTERED INDEX [sqlTransHistID]
    ON [dbo].[tblPoTransInvoice]([TransHistID] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransInvoice';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransInvoice';

