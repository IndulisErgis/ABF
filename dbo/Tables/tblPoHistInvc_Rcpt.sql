CREATE TABLE [dbo].[tblPoHistInvc_Rcpt] (
    [PostRun]    [dbo].[pPostRun] NOT NULL,
    [Qty]        [dbo].[pDec]     NOT NULL,
    [QtySeqNum]  INT              NOT NULL,
    [HistSeqNum] INT              NOT NULL,
    [ReceiptID]  UNIQUEIDENTIFIER CONSTRAINT [DF_tblPoHistInvc_Rcpt_ReceiptID] DEFAULT (newid()) NOT NULL,
    [InvoiceID]  UNIQUEIDENTIFIER CONSTRAINT [DF_tblPoHistInvc_Rcpt_InvoiceID] DEFAULT (newid()) NOT NULL,
    [CF]         XML              NULL,
    CONSTRAINT [PK_tblPoHistInvc_Rcpt] PRIMARY KEY CLUSTERED ([PostRun] ASC, [ReceiptID] ASC, [InvoiceID] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistInvc_Rcpt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistInvc_Rcpt';

