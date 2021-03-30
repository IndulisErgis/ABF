CREATE TABLE [dbo].[tblWmTransSer] (
    [TransId]      INT             NOT NULL,
    [SeqNum]       INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]       [dbo].[pItemID] NULL,
    [LocId]        [dbo].[pLocID]  NULL,
    [LotNum]       [dbo].[pLotNum] NULL,
    [SerNum]       [dbo].[pSerNum] NULL,
    [CostUnit]     [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [CostUnitFgn]  [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [PriceUnit]    [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [PriceUnitFgn] [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [HistSeqNum]   INT             NOT NULL,
    [Cmnt]         VARCHAR (35)    NULL,
    [QtySeqNum]    INT             CONSTRAINT [DF__tblWmTran__QtySe__0691D1DF] DEFAULT ((0)) NOT NULL,
    [ts]           ROWVERSION      NULL,
    [CF]           XML             NULL,
    [ExtLocA]      INT             NULL,
    [ExtLocB]      INT             NULL,
    CONSTRAINT [PK__tblWmTransSer] PRIMARY KEY CLUSTERED ([TransId] ASC, [SeqNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmTransSer';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmTransSer';

