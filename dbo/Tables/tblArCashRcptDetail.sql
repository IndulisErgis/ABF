CREATE TABLE [dbo].[tblArCashRcptDetail] (
    [RcptDetailID]   INT                 IDENTITY (1, 1) NOT NULL,
    [InvcNum]        [dbo].[pInvoiceNum] NOT NULL,
    [PmtAmt]         [dbo].[pDec]        CONSTRAINT [DF_tblArCashRcptDetail_PmtAmt] DEFAULT (0) NULL,
    [Difference]     [dbo].[pDec]        CONSTRAINT [DF_tblArCashRcptDetail_Difference] DEFAULT (0) NULL,
    [PmtAmtFgn]      [dbo].[pDec]        CONSTRAINT [DF_tblArCashRcptDetail_PmtAmtFgn] DEFAULT (0) NULL,
    [DifferenceFgn]  [dbo].[pDec]        CONSTRAINT [DF_tblArCashRcptDetail_DifferenceFgn] DEFAULT (0) NULL,
    [RcptHeaderID]   INT                 CONSTRAINT [DF__tblArCash__RcptH__3F2043C5] DEFAULT (0) NOT NULL,
    [DistCode]       [dbo].[pDistCode]   NULL,
    [ts]             ROWVERSION          NULL,
    [GLAcctGainLoss] [dbo].[pGlAcct]     NULL,
    [CalcGainLoss]   [dbo].[pDec]        CONSTRAINT [DF_tblArCashRcptDetail_CalcGainLoss] DEFAULT ((0)) NULL,
    [InvcExchRate]   [dbo].[pDec]        CONSTRAINT [DF__tblArCashRcptDetail__InvcExchR__47B589C6] DEFAULT ((1)) NULL,
    [CF]             XML                 NULL,
    [InvcType]       SMALLINT            CONSTRAINT [DF_tblArCashRcptDetail_InvcType] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK__tblArCashRcptDet__3A5B8EA8] PRIMARY KEY CLUSTERED ([RcptDetailID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlRcptHeaderID]
    ON [dbo].[tblArCashRcptDetail]([RcptHeaderID] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArCashRcptDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArCashRcptDetail';

