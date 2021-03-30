CREATE TABLE [dbo].[tblSoTransDetail] (
    [TransID]               [dbo].[pTransID]     NOT NULL,
    [EntryNum]              INT                  NOT NULL,
    [ItemJob]               TINYINT              CONSTRAINT [DF__tblSoTran__ItemJ__3E8C123F] DEFAULT (0) NULL,
    [LocId]                 [dbo].[pLocID]       NULL,
    [ItemId]                [dbo].[pItemID]      NULL,
    [JobId]                 VARCHAR (10)         NULL,
    [PhaseId]               VARCHAR (10)         NULL,
    [JobCompleteYN]         BIT                  CONSTRAINT [DF__tblSoTran__JobCo__3F803678] DEFAULT (0) NULL,
    [ItemType]              TINYINT              CONSTRAINT [DF__tblSoTran__ItemT__40745AB1] DEFAULT (0) NULL,
    [Descr]                 [dbo].[pDescription] NULL,
    [AddnlDescr]            TEXT                 NULL,
    [CatId]                 VARCHAR (2)          NULL,
    [TaxClass]              TINYINT              CONSTRAINT [DF__tblSoTran__TaxCl__41687EEA] DEFAULT (0) NOT NULL,
    [AcctCode]              [dbo].[pGLAcctCode]  NULL,
    [GLAcctSales]           [dbo].[pGlAcct]      NULL,
    [GLAcctCOGS]            [dbo].[pGlAcct]      NULL,
    [GLAcctInv]             [dbo].[pGlAcct]      NULL,
    [QtyOrdSell]            [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_QtyOrdSell] DEFAULT (0) NULL,
    [UnitsSell]             [dbo].[pUom]         NULL,
    [UnitsBase]             [dbo].[pUom]         NULL,
    [QtyShipSell]           [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_QtyShipSell] DEFAULT (0) NULL,
    [QtyShipBase]           [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_QtyShipBase] DEFAULT (0) NULL,
    [QtyBackordSell]        [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_QtyBackordSell] DEFAULT (0) NULL,
    [PriceID]               VARCHAR (10)         NULL,
    [UnitPriceSell]         [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_UnitPriceSell] DEFAULT (0) NULL,
    [UnitPriceSellFgn]      [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_UnitPriceSellFgn] DEFAULT (0) NULL,
    [UnitCostSell]          [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_UnitCostSell] DEFAULT (0) NULL,
    [UnitCostSellFgn]       [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_UnitCostSellFgn] DEFAULT (0) NULL,
    [PromoID]               VARCHAR (10)         NULL,
    [ActShipDate]           DATETIME             NULL,
    [EffectiveRate]         [dbo].[pDec]         CONSTRAINT [DF__tblSoTran__Effec__49FDC4EB] DEFAULT (0) NULL,
    [OrigOrderQty]          [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_OrigOrderQty] DEFAULT (0) NULL,
    [BinNum]                VARCHAR (10)         NULL,
    [ConversionFactor]      [dbo].[pDec]         CONSTRAINT [DF__tblSoTran__Conve__4BE60D5D] DEFAULT (1) NULL,
    [LottedYN]              BIT                  CONSTRAINT [DF__tblSoTran__Lotte__4CDA3196] DEFAULT (0) NULL,
    [InItemYN]              BIT                  CONSTRAINT [DF__tblSoTran__InIte__4DCE55CF] DEFAULT (1) NULL,
    [HistSeqNum]            INT                  CONSTRAINT [DF__tblSoTran__HistS__4EC27A08] DEFAULT (0) NULL,
    [GrpId]                 INT                  NULL,
    [Kit]                   BIT                  CONSTRAINT [DF_tblSoTransDetail_Kit] DEFAULT (0) NULL,
    [KitQty]                [dbo].[pDec]         CONSTRAINT [DF__tblSoTran__KitQt__4FB69E41] DEFAULT (1) NULL,
    [KitQtyBackOrdered]     [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_KitQtyBackOrdered] DEFAULT (0) NULL,
    [OriCompQty]            [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_OriCompQty] DEFAULT (0) NULL,
    [QtySeqNum_Cmtd]        INT                  CONSTRAINT [DF_tblSoTransDetail_QtySeqNum_Cmtd] DEFAULT (0) NULL,
    [ts]                    ROWVERSION           NULL,
    [ReqShipDate]           DATETIME             NULL,
    [PriceExt]              [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_PriceExt] DEFAULT ((0)) NULL,
    [PriceExtFgn]           [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_PriceExtFgn] DEFAULT ((0)) NULL,
    [CostExtFgn]            [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_CostExtFgn] DEFAULT ((0)) NULL,
    [CostExt]               [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_CostExt] DEFAULT ((0)) NULL,
    [BlanketDtlRef]         INT                  NULL,
    [BOLNum]                VARCHAR (17)         NULL,
    [LineSeq]               INT                  NULL,
    [LinkSeqNum]            INT                  NULL,
    [PriceAdjAmt]           [dbo].[pDec]         DEFAULT ((0)) NULL,
    [PriceAdjAmtFgn]        [dbo].[pDec]         DEFAULT ((0)) NULL,
    [PriceAdjPct]           [dbo].[pDec]         DEFAULT ((0)) NULL,
    [PriceAdjType]          TINYINT              DEFAULT ((0)) NULL,
    [Rep1CommRate]          [dbo].[pDec]         DEFAULT ((0)) NULL,
    [Rep1Id]                [dbo].[pSalesRep]    NULL,
    [Rep1Pct]               [dbo].[pDec]         DEFAULT ((0)) NULL,
    [Rep2CommRate]          [dbo].[pDec]         DEFAULT ((0)) NULL,
    [Rep2Id]                [dbo].[pSalesRep]    NULL,
    [Rep2Pct]               [dbo].[pDec]         DEFAULT ((0)) NULL,
    [ResCode]               VARCHAR (10)         NULL,
    [Status]                TINYINT              DEFAULT ((0)) NULL,
    [TotQtyOrdSell]         [dbo].[pDec]         DEFAULT ((0)) NULL,
    [UnitCommBasis]         [dbo].[pDec]         DEFAULT ((0)) NULL,
    [UnitCommBasisFgn]      [dbo].[pDec]         DEFAULT ((0)) NULL,
    [UnitPriceSellBasis]    [dbo].[pDec]         DEFAULT ((0)) NULL,
    [UnitPriceSellBasisFgn] [dbo].[pDec]         DEFAULT ((0)) NULL,
    [TotQtyShipSell]        [dbo].[pDec]         CONSTRAINT [DF_tblSoTransDetail_TotQtyShipSell] DEFAULT ((0)) NULL,
    [QtySeqNum]             INT                  CONSTRAINT [DF_tblSoTransDetail_QtySeqNum] DEFAULT ((0)) NULL,
    [CF]                    XML                  NULL,
    [TotCostShipSell]       [dbo].[pDecimal]     CONSTRAINT [DF_tblSoTransDetail_TotCostShipSell] DEFAULT ((0)) NOT NULL,
    [CustomerPartNumber]    [dbo].[pDescription] NULL,
    CONSTRAINT [PK_tblSoTransDetail] PRIMARY KEY CLUSTERED ([TransID] ASC, [EntryNum] ASC)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoTransDetail] TO [WebUserRole]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoTransDetail] TO [WebUserRole]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblSoTransDetail] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoTransDetail] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoTransDetail] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblSoTransDetail] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransDetail';

