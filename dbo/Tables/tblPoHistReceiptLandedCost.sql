CREATE TABLE [dbo].[tblPoHistReceiptLandedCost] (
    [PostRun]       [dbo].[pPostRun] NOT NULL,
    [LCTransSeqNum] INT              NOT NULL,
    [Amount]        [dbo].[pDec]     NOT NULL,
    [PostedAmount]  [dbo].[pDec]     NOT NULL,
    [ReceiptID]     UNIQUEIDENTIFIER CONSTRAINT [DF_tblPoHistReceiptLandedCost_ReceiptID] DEFAULT (newid()) NOT NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK_tblPoHistReceiptLandedCost] PRIMARY KEY CLUSTERED ([PostRun] ASC, [ReceiptID] ASC, [LCTransSeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistReceiptLandedCost';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistReceiptLandedCost';

