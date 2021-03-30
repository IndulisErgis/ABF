CREATE TABLE [dbo].[tblWmHistTransferPick] (
    [ID]            BIGINT           IDENTITY (1, 1) NOT NULL,
    [HeaderID]      BIGINT           NOT NULL,
    [TranPickKey]   INT              NOT NULL,
    [SerNum]        [dbo].[pSerNum]  NULL,
    [LotNum]        [dbo].[pLotNum]  NULL,
    [ExtLocA]       INT              NULL,
    [ExtLocB]       INT              NULL,
    [ExtLocAID]     NVARCHAR (10)    NULL,
    [ExtLocBID]     NVARCHAR (10)    NULL,
    [Qty]           [dbo].[pDecimal] NOT NULL,
    [QtyBase]       [dbo].[pDecimal] NOT NULL,
    [UOM]           [dbo].[pUom]     NOT NULL,
    [CostUnit]      [dbo].[pDecimal] NOT NULL,
    [CostExt]       [dbo].[pDecimal] NOT NULL,
    [EntryDate]     DATETIME         NOT NULL,
    [TransDate]     DATETIME         NOT NULL,
    [FiscalPeriod]  SMALLINT         NOT NULL,
    [FiscalYear]    SMALLINT         NOT NULL,
    [QOHSeqNum]     INT              NOT NULL,
    [QOHSeqNumExt]  INT              NOT NULL,
    [QOOSeqNum]     INT              NOT NULL,
    [HistSeqNum]    INT              NOT NULL,
    [HistSeqNumSer] INT              NOT NULL,
    [CF]            XML              NULL,
    CONSTRAINT [PK_tblWmHistTransferPick] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblWmHistTransferPick_HeaderIDTranPickKey]
    ON [dbo].[tblWmHistTransferPick]([HeaderID] ASC, [TranPickKey] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.15141.1756', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistTransferPick';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 15141', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblWmHistTransferPick';

