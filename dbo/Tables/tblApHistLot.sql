CREATE TABLE [dbo].[tblApHistLot] (
    [PostRun]     [dbo].[pPostRun]    CONSTRAINT [DF__tblApHist__PostR__63FCC2B9] DEFAULT (0) NOT NULL,
    [TransId]     [dbo].[pTransID]    NOT NULL,
    [InvoiceNum]  [dbo].[pInvoiceNum] NOT NULL,
    [EntryNum]    INT                 NOT NULL,
    [SeqNum]      VARCHAR (15)        NOT NULL,
    [ItemId]      [dbo].[pItemID]     NULL,
    [LocId]       [dbo].[pLocID]      NULL,
    [LotNum]      [dbo].[pLotNum]     NULL,
    [QtyOrder]    [dbo].[pDec]        CONSTRAINT [DF__tblApHist__QtyOr__65E50B2B] DEFAULT (0) NULL,
    [QtyFilled]   [dbo].[pDec]        CONSTRAINT [DF__tblApHist__QtyFi__66D92F64] DEFAULT (0) NULL,
    [QtyBkord]    [dbo].[pDec]        CONSTRAINT [DF__tblApHist__QtyBk__67CD539D] DEFAULT (0) NULL,
    [CostUnit]    [dbo].[pDec]        CONSTRAINT [DF__tblApHist__CostU__68C177D6] DEFAULT (0) NULL,
    [CostUnitFgn] [dbo].[pDec]        CONSTRAINT [DF__tblApHist__CostU__69B59C0F] DEFAULT (0) NULL,
    [HistSeqNum]  INT                 NULL,
    [Cmnt]        VARCHAR (35)        NULL,
    [CF]          XML                 NULL,
    CONSTRAINT [PK_tblApHistLot] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [InvoiceNum] ASC, [EntryNum] ASC, [SeqNum] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblApHistLot] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblApHistLot] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblApHistLot] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblApHistLot] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistLot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistLot';

