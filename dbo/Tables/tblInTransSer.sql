CREATE TABLE [dbo].[tblInTransSer] (
    [TransId]      INT             NOT NULL,
    [SeqNum]       INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]       [dbo].[pItemID] NULL,
    [LocId]        [dbo].[pLocID]  NULL,
    [LotNum]       [dbo].[pLotNum] NULL,
    [SerNum]       [dbo].[pSerNum] NULL,
    [CostUnit]     [dbo].[pDec]    CONSTRAINT [DF__tblInTran__CostU__34E2AC74] DEFAULT (0) NULL,
    [CostUnitFgn]  [dbo].[pDec]    CONSTRAINT [DF__tblInTran__CostU__35D6D0AD] DEFAULT (0) NULL,
    [PriceUnit]    [dbo].[pDec]    CONSTRAINT [DF__tblInTran__Price__36CAF4E6] DEFAULT (0) NULL,
    [PriceUnitFgn] [dbo].[pDec]    CONSTRAINT [DF__tblInTran__Price__37BF191F] DEFAULT (0) NULL,
    [HistSeqNum]   INT             NULL,
    [Cmnt]         VARCHAR (35)    NULL,
    [QtySeqNum]    INT             CONSTRAINT [DF_tblInTransSer_QtySeqNum] DEFAULT (0) NULL,
    [ts]           ROWVERSION      NULL,
    [CF]           XML             NULL,
    [ExtLocA]      INT             NULL,
    [ExtLocB]      INT             NULL,
    CONSTRAINT [PK__tblInTransSer__38B96646] PRIMARY KEY CLUSTERED ([TransId] ASC, [SeqNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInTransSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInTransSer';

