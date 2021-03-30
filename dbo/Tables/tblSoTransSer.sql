CREATE TABLE [dbo].[tblSoTransSer] (
    [TransId]      [dbo].[pTransID] NOT NULL,
    [EntryNum]     INT              NOT NULL,
    [SeqNum]       INT              IDENTITY (1, 1) NOT NULL,
    [ItemId]       [dbo].[pItemID]  NOT NULL,
    [LocId]        [dbo].[pLocID]   NOT NULL,
    [LotNum]       [dbo].[pLotNum]  NULL,
    [SerNum]       [dbo].[pSerNum]  NOT NULL,
    [CostUnit]     [dbo].[pDec]     CONSTRAINT [DF_tblSoTransSer_CostUnit] DEFAULT (0) NOT NULL,
    [CostUnitFgn]  [dbo].[pDec]     CONSTRAINT [DF_tblSoTransSer_CostUnitFgn] DEFAULT (0) NOT NULL,
    [PriceUnit]    [dbo].[pDec]     CONSTRAINT [DF_tblSoTransSer_PriceUnit] DEFAULT (0) NOT NULL,
    [PriceUnitFgn] [dbo].[pDec]     CONSTRAINT [DF_tblSoTransSer_PriceUnitFgn] DEFAULT (0) NOT NULL,
    [HistSeqNum]   INT              CONSTRAINT [DF_tblSoTransSer_HistSeqNum] DEFAULT (0) NOT NULL,
    [Cmnt]         VARCHAR (35)     NULL,
    [QtySeqNum]    INT              CONSTRAINT [DF_tblSoTransSer_QtySeqNum] DEFAULT (0) NOT NULL,
    [ts]           ROWVERSION       NULL,
    [CF]           XML              NULL,
    [ExtLocA]      INT              NULL,
    [ExtLocB]      INT              NULL,
    CONSTRAINT [PK_tblSoTransSer] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblSoTransSer] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoTransSer] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoTransSer] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblSoTransSer] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransSer';

