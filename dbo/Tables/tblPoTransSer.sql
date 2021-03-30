CREATE TABLE [dbo].[tblPoTransSer] (
    [TransId]         [dbo].[pTransID]    NOT NULL,
    [EntryNum]        INT                 CONSTRAINT [DF_tblPoTransSer_EntryNum] DEFAULT ((0)) NOT NULL,
    [RcptNum]         [dbo].[pInvoiceNum] NOT NULL,
    [LotNum]          [dbo].[pLotNum]     NULL,
    [SerNum]          [dbo].[pSerNum]     NOT NULL,
    [InvcNum]         [dbo].[pInvoiceNum] NULL,
    [SerCmnt]         VARCHAR (35)        NULL,
    [RcptUnitCost]    [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__RcptU__231901F4] DEFAULT (0) NULL,
    [RcptUnitCostFgn] [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__RcptU__240D262D] DEFAULT (0) NULL,
    [RcptStatus]      TINYINT             CONSTRAINT [DF__tblPoTran__RcptS__25014A66] DEFAULT (0) NULL,
    [InvcUnitCost]    [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__InvcU__25F56E9F] DEFAULT (0) NULL,
    [InvcUnitCostFgn] [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__InvcU__26E992D8] DEFAULT (0) NULL,
    [InvcStatus]      TINYINT             CONSTRAINT [DF__tblPoTran__InvcS__27DDB711] DEFAULT (0) NULL,
    [SerHistSeqNum]   INT                 CONSTRAINT [DF__tblPoTran__SerHi__28D1DB4A] DEFAULT (0) NULL,
    [ts]              ROWVERSION          NULL,
    [ExchRateSRec]    [dbo].[pDec]        CONSTRAINT [DF_tblPoTransSer_ExchRate] DEFAULT ((1)) NULL,
    [ExchRateSInv]    [dbo].[pDec]        CONSTRAINT [DF_tblPoTransSer_ExchRateSInv] DEFAULT ((1)) NULL,
    [CF]              XML                 NULL,
    [ExtLocA]         INT                 NULL,
    [ExtLocB]         INT                 NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransSer';

