CREATE TABLE [dbo].[tblPoTransInvc_Rcpt] (
    [Qty]        [dbo].[pDec]     CONSTRAINT [DF_tblPoTransInvc_Rcpt_Qty] DEFAULT (0) NOT NULL,
    [QtySeqNum]  INT              CONSTRAINT [DF_tblPoTransInvc_Rcpt_QtySeqNum] DEFAULT (0) NOT NULL,
    [HistSeqNum] INT              CONSTRAINT [DF_tblPoTransInvc_Rcpt_HistSeqNum] DEFAULT (0) NOT NULL,
    [ReceiptID]  UNIQUEIDENTIFIER CONSTRAINT [DF_tblPoTransInvc_Rcpt_ReceiptID] DEFAULT (newid()) NOT NULL,
    [InvoiceID]  UNIQUEIDENTIFIER CONSTRAINT [DF_tblPoTransInvc_Rcpt_InvoiceID] DEFAULT (newid()) NOT NULL,
    [CF]         XML              NULL,
    [ts]         ROWVERSION       NULL,
    CONSTRAINT [PK_tblPoTransInvc_Rcpt] PRIMARY KEY CLUSTERED ([ReceiptID] ASC, [InvoiceID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransInvc_Rcpt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransInvc_Rcpt';

