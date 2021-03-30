CREATE TABLE [dbo].[tblApTransSer] (
    [TransId]      [dbo].[pTransID] NOT NULL,
    [EntryNum]     INT              NOT NULL,
    [SeqNum]       INT              IDENTITY (1, 1) NOT NULL,
    [ItemId]       [dbo].[pItemID]  NULL,
    [LocId]        [dbo].[pLocID]   NULL,
    [LotNum]       [dbo].[pLotNum]  NULL,
    [SerNum]       [dbo].[pSerNum]  NULL,
    [CostUnit]     [dbo].[pDec]     CONSTRAINT [DF__tblApTran__CostU__6F046111] DEFAULT (0) NULL,
    [PriceUnit]    [dbo].[pDec]     CONSTRAINT [DF__tblApTran__Price__6FF8854A] DEFAULT (0) NULL,
    [CostUnitFgn]  [dbo].[pDec]     CONSTRAINT [DF__tblApTran__CostU__70ECA983] DEFAULT (0) NULL,
    [PriceUnitFgn] [dbo].[pDec]     CONSTRAINT [DF__tblApTran__Price__71E0CDBC] DEFAULT (0) NULL,
    [HistSeqNum]   INT              NULL,
    [Cmnt]         VARCHAR (35)     NULL,
    [QtySeqNum]    INT              CONSTRAINT [DF_tblApTransSer_QtySeqNum] DEFAULT (0) NULL,
    [ts]           ROWVERSION       NULL,
    [CF]           XML              NULL,
    [ExtLocA]      INT              NULL,
    [ExtLocB]      INT              NULL,
    CONSTRAINT [PK_tblApTransSer] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransSer';

