CREATE TABLE [dbo].[tblPoTransReceipt] (
    [TransID]     [dbo].[pTransID]    NOT NULL,
    [ReceiptNum]  [dbo].[pInvoiceNum] NOT NULL,
    [ReceiptDate] DATETIME            CONSTRAINT [DF__tblPoTran__Recei__14CAE29D] DEFAULT (getdate()) NULL,
    [GlPeriod]    SMALLINT            CONSTRAINT [DF__tblPoTran__GlPer__15BF06D6] DEFAULT (0) NULL,
    [FiscalYear]  SMALLINT            CONSTRAINT [DF__tblPoTran__Fisca__16B32B0F] DEFAULT (0) NULL,
    [ts]          ROWVERSION          NULL,
    [ExchRate]    [dbo].[pDec]        DEFAULT ((1)) NULL,
    [CF]          XML                 NULL,
    CONSTRAINT [PK_tblPoTransReceipt] PRIMARY KEY CLUSTERED ([TransID] ASC, [ReceiptNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransReceipt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransReceipt';

