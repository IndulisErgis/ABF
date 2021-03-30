CREATE TABLE [dbo].[tblBmWorkOrderSer] (
    [TransId]      [dbo].[pTransID] NOT NULL,
    [EntryNum]     INT              CONSTRAINT [DF__tblBmWork__Entry__6B64E1A4] DEFAULT (0) NOT NULL,
    [SeqNum]       INT              IDENTITY (1, 1) NOT NULL,
    [ItemId]       [dbo].[pItemID]  NOT NULL,
    [LocId]        [dbo].[pLocID]   NOT NULL,
    [LotNum]       [dbo].[pLotNum]  NULL,
    [SerNum]       [dbo].[pSerNum]  NOT NULL,
    [CostUnit]     [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__CostU__6C5905DD] DEFAULT (0) NULL,
    [CostUnitFgn]  [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__CostU__6D4D2A16] DEFAULT (0) NULL,
    [PriceUnit]    [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__Price__6E414E4F] DEFAULT (0) NULL,
    [PriceUnitFgn] [dbo].[pDec]     CONSTRAINT [DF__tblBmWork__Price__6F357288] DEFAULT (0) NULL,
    [HistSeqNum]   INT              CONSTRAINT [DF__tblBmWork__HistS__702996C1] DEFAULT (0) NULL,
    [Cmnt]         VARCHAR (35)     NULL,
    [QtySeqNum]    INT              CONSTRAINT [DF__tblBmWork__QtySe__711DBAFA] DEFAULT (0) NULL,
    [ts]           ROWVERSION       NULL,
    [CF]           XML              NULL,
    [ExtLocA]      INT              NULL,
    [ExtLocB]      INT              NULL,
    CONSTRAINT [PK__tblBmWorkOrderSer] PRIMARY KEY CLUSTERED ([TransId] ASC, [EntryNum] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblBmWorkOrderSer] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblBmWorkOrderSer] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblBmWorkOrderSer] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblBmWorkOrderSer] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderSer';

