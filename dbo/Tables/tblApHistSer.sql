CREATE TABLE [dbo].[tblApHistSer] (
    [PostRun]      [dbo].[pPostRun]    CONSTRAINT [DF__tblApHist__PostR__6C9208BA] DEFAULT (0) NOT NULL,
    [TransId]      [dbo].[pTransID]    NOT NULL,
    [InvoiceNum]   [dbo].[pInvoiceNum] NOT NULL,
    [EntryNum]     INT                 NOT NULL,
    [SeqNum]       VARCHAR (15)        NOT NULL,
    [LotNum]       [dbo].[pLotNum]     NULL,
    [SerNum]       [dbo].[pSerNum]     NOT NULL,
    [ItemId]       [dbo].[pItemID]     NULL,
    [LocId]        [dbo].[pLocID]      NULL,
    [CostUnit]     [dbo].[pDec]        CONSTRAINT [DF__tblApHist__CostU__6E7A512C] DEFAULT (0) NULL,
    [PriceUnit]    [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Price__6F6E7565] DEFAULT (0) NULL,
    [CostUnitFgn]  [dbo].[pDec]        CONSTRAINT [DF__tblApHist__CostU__7062999E] DEFAULT (0) NULL,
    [PriceUnitFgn] [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Price__7156BDD7] DEFAULT (0) NULL,
    [HistSeqNum]   INT                 NULL,
    [Cmnt]         VARCHAR (35)        NULL,
    [CF]           XML                 NULL,
    [ExtLocAID]    VARCHAR (10)        NULL,
    [ExtLocBID]    VARCHAR (10)        NULL,
    CONSTRAINT [PK_tblApHistSer] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [InvoiceNum] ASC, [EntryNum] ASC, [SeqNum] ASC, [SerNum] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblApHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblApHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblApHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblApHistSer] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistSer';

