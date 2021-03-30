CREATE TABLE [dbo].[tblPoHistInvoice] (
    [PostRun]     [dbo].[pPostRun]    NOT NULL,
    [TransID]     [dbo].[pTransID]    NOT NULL,
    [EntryNum]    INT                 NOT NULL,
    [InvoiceNum]  [dbo].[pInvoiceNum] NOT NULL,
    [Status]      TINYINT             NULL,
    [Qty]         [dbo].[pDec]        NULL,
    [UnitCost]    [dbo].[pDec]        NULL,
    [UnitCostFgn] [dbo].[pDec]        NULL,
    [ExtCost]     [dbo].[pDec]        NULL,
    [ExtCostFgn]  [dbo].[pDec]        NULL,
    [HistSeqNum]  INT                 NULL,
    [AvgRcptCost] [dbo].[pDec]        NULL,
    [TransHistID] VARCHAR (10)        NULL,
    [QtySeqNum]   INT                 NULL,
    [InvoiceID]   UNIQUEIDENTIFIER    CONSTRAINT [DF_tblPoHistInvoice_InvoiceID] DEFAULT (newid()) NOT NULL,
    [CF]          XML                 NULL,
    CONSTRAINT [PK_tblPoHistInvoice] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransID] ASC, [EntryNum] ASC, [InvoiceNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlTransHistID]
    ON [dbo].[tblPoHistInvoice]([TransHistID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistInvoice';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistInvoice';

