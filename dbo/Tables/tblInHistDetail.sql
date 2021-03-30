CREATE TABLE [dbo].[tblInHistDetail] (
    [HistSeqNum]      INT              IDENTITY (1, 1) NOT NULL,
    [HistSeqNum_Rcpt] INT              DEFAULT ((0)) NOT NULL,
    [ItemId]          [dbo].[pItemID]  NULL,
    [LocId]           [dbo].[pLocID]   NULL,
    [ItemType]        TINYINT          DEFAULT ((0)) NULL,
    [LottedYN]        BIT              DEFAULT ((0)) NULL,
    [TransType]       TINYINT          DEFAULT ((1)) NULL,
    [SumYear]         SMALLINT         DEFAULT ((0)) NULL,
    [SumPeriod]       SMALLINT         DEFAULT ((0)) NULL,
    [GLPeriod]        SMALLINT         DEFAULT ((0)) NULL,
    [AppId]           CHAR (2)         DEFAULT ('IN') NULL,
    [BatchId]         [dbo].[pBatchID] NULL,
    [TransId]         NVARCHAR (255)   NULL,
    [RefId]           VARCHAR (15)     NULL,
    [SrceID]          VARCHAR (10)     NULL,
    [TransDate]       DATETIME         DEFAULT (getdate()) NULL,
    [Uom]             [dbo].[pUom]     NULL,
    [UomBase]         [dbo].[pUom]     NULL,
    [ConvFactor]      [dbo].[pDec]     DEFAULT ((1)) NOT NULL,
    [Qty]             [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [CostExt]         [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [CostStd]         [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [PriceExt]        [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [CostUnit]        [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [PriceUnit]       [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [Source]          TINYINT          DEFAULT ((0)) NOT NULL,
    [Qty_Invc]        [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [CostExt_Invc]    [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [DropShipYn]      BIT              DEFAULT ((0)) NOT NULL,
    [LotNum]          [dbo].[pLotNum]  NULL,
    [CF]              XML              NULL,
    [EntryDate]       DATETIME         DEFAULT (getdate()) NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInHistDetail';

