CREATE TABLE [dbo].[tblBmWorkOrderHistSer] (
    [PostRun]      [dbo].[pPostRun] CONSTRAINT [DF__tblBmWork__PostR__11BF94B6] DEFAULT (0) NOT NULL,
    [TransId]      [dbo].[pTransID] NOT NULL,
    [EntryNum]     INT              CONSTRAINT [DF__tblBmWork__Entry__12B3B8EF] DEFAULT (0) NOT NULL,
    [SeqNum]       INT              NOT NULL,
    [ItemId]       [dbo].[pItemID]  NOT NULL,
    [LocId]        [dbo].[pLocID]   NOT NULL,
    [LotNum]       [dbo].[pLotNum]  NULL,
    [SerNum]       [dbo].[pSerNum]  NOT NULL,
    [CostUnit]     [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__CostU__13A7DD28] DEFAULT (0) NULL,
    [CostUnitFgn]  [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__CostU__149C0161] DEFAULT (0) NULL,
    [PriceUnit]    [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__Price__1590259A] DEFAULT (0) NULL,
    [PriceUnitFgn] [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__Price__168449D3] DEFAULT (0) NULL,
    [HistSeqNum]   INT              CONSTRAINT [DF__tblBmWork__HistS__17786E0C] DEFAULT (0) NULL,
    [Cmnt]         VARCHAR (35)     NULL,
    [QtySeqNum]    INT              CONSTRAINT [DF__tblBmWork__QtySe__186C9245] DEFAULT (0) NULL,
    [ts]           ROWVERSION       NULL,
    [CF]           XML              NULL,
    [ExtLocAID]    VARCHAR (10)     NULL,
    [ExtLocBID]    VARCHAR (10)     NULL,
    CONSTRAINT [PK__tblBmWorkOrderHistSer] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [EntryNum] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderHistSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderHistSer';

