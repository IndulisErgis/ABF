CREATE TABLE [dbo].[tblArHistSer] (
    [PostRun]      [dbo].[pPostRun] CONSTRAINT [DF__tblArHist__PostR__7917DB30] DEFAULT (0) NOT NULL,
    [TransId]      [dbo].[pTransID] NOT NULL,
    [EntryNum]     INT              NOT NULL,
    [SeqNum]       INT              CONSTRAINT [DF__tblArHist__SeqNu__7B0023A2] DEFAULT (0) NOT NULL,
    [ItemId]       [dbo].[pItemID]  NULL,
    [LocId]        [dbo].[pLocID]   NULL,
    [LotNum]       [dbo].[pLotNum]  NULL,
    [SerNum]       [dbo].[pSerNum]  NULL,
    [CostUnit]     [dbo].[pDec]     CONSTRAINT [DF_tblArHistSer_CostUnit] DEFAULT (0) NULL,
    [PriceUnit]    [dbo].[pDec]     CONSTRAINT [DF_tblArHistSer_PriceUnit] DEFAULT (0) NULL,
    [CostUnitFgn]  [dbo].[pDec]     CONSTRAINT [DF_tblArHistSer_CostUnitFgn] DEFAULT (0) NULL,
    [PriceUnitFgn] [dbo].[pDec]     CONSTRAINT [DF_tblArHistSer_PriceUnitFgn] DEFAULT (0) NULL,
    [HistSeqNum]   INT              NULL,
    [Cmnt]         VARCHAR (35)     NULL,
    [CF]           XML              NULL,
    [ExtLocAID]    VARCHAR (10)     NULL,
    [ExtLocBID]    VARCHAR (10)     NULL,
    CONSTRAINT [PK_tblArHistSer] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [EntryNum] ASC, [SeqNum] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblArHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblArHistSer] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblArHistSer] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistSer';

