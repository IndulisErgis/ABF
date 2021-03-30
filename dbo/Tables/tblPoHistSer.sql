CREATE TABLE [dbo].[tblPoHistSer] (
    [PostRun]         [dbo].[pPostRun]    NOT NULL,
    [TransId]         [dbo].[pTransID]    NOT NULL,
    [EntryNum]        INT                 NOT NULL,
    [RcptNum]         [dbo].[pInvoiceNum] NOT NULL,
    [SerNum]          [dbo].[pSerNum]     NOT NULL,
    [LotNum]          [dbo].[pLotNum]     NULL,
    [InvcNum]         [dbo].[pInvoiceNum] NULL,
    [SerCmnt]         VARCHAR (35)        NULL,
    [RcptUnitCost]    [dbo].[pDec]        NULL,
    [RcptUnitCostFgn] [dbo].[pDec]        NULL,
    [RcptStatus]      TINYINT             NULL,
    [InvcUnitCost]    [dbo].[pDec]        NULL,
    [InvcUnitCostFgn] [dbo].[pDec]        NULL,
    [InvcStatus]      TINYINT             NULL,
    [SerHistSeqNum]   INT                 NULL,
    [ts]              ROWVERSION          NULL,
    [ExchRateSInv]    [dbo].[pDec]        NULL,
    [ExchRateSRec]    [dbo].[pDec]        NULL,
    [CF]              XML                 NULL,
    [ExtLocAID]       VARCHAR (10)        NULL,
    [ExtLocBID]       VARCHAR (10)        NULL,
    CONSTRAINT [PK_tblPoHistSer] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [EntryNum] ASC, [RcptNum] ASC, [SerNum] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPoHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPoHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPoHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPoHistSer] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistSer';

