CREATE TABLE [dbo].[tblPoHistReceipt] (
    [PostRun]     [dbo].[pPostRun]    NOT NULL,
    [TransID]     [dbo].[pTransID]    NOT NULL,
    [ReceiptNum]  [dbo].[pInvoiceNum] NOT NULL,
    [ReceiptDate] DATETIME            NULL,
    [GlPeriod]    SMALLINT            NULL,
    [FiscalYear]  SMALLINT            NULL,
    [ExchRate]    [dbo].[pDec]        DEFAULT ((1)) NULL,
    [CF]          XML                 NULL,
    CONSTRAINT [PK_tblPoHistReceipt] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransID] ASC, [ReceiptNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistReceipt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistReceipt';

