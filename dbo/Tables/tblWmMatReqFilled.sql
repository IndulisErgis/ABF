CREATE TABLE [dbo].[tblWmMatReqFilled] (
    [TranKey]       INT             NOT NULL,
    [LineNum]       INT             NOT NULL,
    [SeqNum]        INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]        [dbo].[pItemID] NOT NULL,
    [LocId]         [dbo].[pLocID]  NOT NULL,
    [SerNum]        [dbo].[pSerNum] NULL,
    [LotNum]        [dbo].[pLotNum] NULL,
    [ExtLocA]       INT             NULL,
    [ExtLocAID]     VARCHAR (10)    NULL,
    [ExtLocB]       INT             NULL,
    [ExtLocBID]     VARCHAR (10)    NULL,
    [Qty]           [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [UOM]           [dbo].[pUom]    NOT NULL,
    [UnitCost]      [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [EntryDate]     DATETIME        NOT NULL,
    [TransDate]     DATETIME        NOT NULL,
    [GlPeriod]      SMALLINT        DEFAULT ((0)) NOT NULL,
    [GlYear]        SMALLINT        DEFAULT ((0)) NOT NULL,
    [QtySeqNum]     INT             DEFAULT ((0)) NOT NULL,
    [QtySeqNum_Ext] INT             DEFAULT ((0)) NOT NULL,
    [HistSeqNum]    INT             DEFAULT ((0)) NOT NULL,
    [HistSeqNumSer] INT             DEFAULT ((0)) NOT NULL,
    [HistSeqNumLot] INT             DEFAULT ((0)) NOT NULL,
    [ts]            ROWVERSION      NULL,
    [CF]            XML             NULL,
    [Status]        TINYINT         CONSTRAINT [DF_tblWmMatReqFilled_Status] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__tblWmMatReqFilled] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblWmMatReqFilled_TranKeyLineNumSeqNum]
    ON [dbo].[tblWmMatReqFilled]([TranKey] ASC, [LineNum] ASC, [SeqNum] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmMatReqFilled';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmMatReqFilled';

