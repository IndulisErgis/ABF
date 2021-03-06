CREATE TABLE [dbo].[tblPoTransReceiptLandedCost] (
    [LCTransSeqNum] INT              NOT NULL,
    [Amount]        [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [PostedAmount]  [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [ReceiptID]     UNIQUEIDENTIFIER CONSTRAINT [DF_tblPoTransReceiptLandedCost_ReceiptID] DEFAULT (newid()) NOT NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK_tblPoTransReceiptLandedCost] PRIMARY KEY CLUSTERED ([ReceiptID] ASC, [LCTransSeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransReceiptLandedCost';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransReceiptLandedCost';

