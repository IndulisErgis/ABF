CREATE TABLE [dbo].[tblArHistDetail] (
    [PostRun]               [dbo].[pPostRun]     NOT NULL,
    [TransID]               [dbo].[pTransID]     NOT NULL,
    [EntryNum]              INT                  NOT NULL,
    [ItemJob]               TINYINT              CONSTRAINT [DF__tblArHist__ItemJ__10304AB2] DEFAULT (0) NULL,
    [WhseId]                [dbo].[pLocID]       NULL,
    [PartId]                [dbo].[pItemID]      NULL,
    [JobId]                 VARCHAR (10)         NULL,
    [PhaseId]               VARCHAR (10)         NULL,
    [JobCompleteYN]         BIT                  CONSTRAINT [DF__tblArHist__JobCo__11246EEB] DEFAULT (0) NULL,
    [PartType]              TINYINT              CONSTRAINT [DF__tblArHist__PartT__12189324] DEFAULT (0) NULL,
    [Desc]                  [dbo].[pDescription] NULL,
    [AddnlDesc]             TEXT                 NULL,
    [CatId]                 VARCHAR (2)          NULL,
    [TaxClass]              TINYINT              CONSTRAINT [DF__tblArHist__TaxCl__130CB75D] DEFAULT (0) NOT NULL,
    [AcctCode]              VARCHAR (6)          NULL,
    [GLAcctSales]           [dbo].[pGlAcct]      NULL,
    [GLAcctCOGS]            [dbo].[pGlAcct]      NULL,
    [GLAcctInv]             [dbo].[pGlAcct]      NULL,
    [QtyOrdSell]            [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_QtyOrdSell] DEFAULT (0) NULL,
    [UnitsSell]             [dbo].[pUom]         NULL,
    [UnitsBase]             [dbo].[pUom]         NULL,
    [QtyShipSell]           [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_QtyShipSell] DEFAULT (0) NULL,
    [QtyShipBase]           [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_QtyShipBase] DEFAULT (0) NULL,
    [QtyBackordSell]        [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_QtyBackordSell] DEFAULT (0) NULL,
    [PriceID]               VARCHAR (10)         NULL,
    [UnitPriceSell]         [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_UnitPriceSell] DEFAULT (0) NULL,
    [UnitPriceSellFgn]      [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_UnitPriceSellFgn] DEFAULT (0) NULL,
    [UnitCostSell]          [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_UnitCostSell] DEFAULT (0) NULL,
    [UnitCostSellFgn]       [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_UnitCostSellFgn] DEFAULT (0) NULL,
    [PromoID]               VARCHAR (10)         NULL,
    [ActShipDate]           DATETIME             NULL,
    [EffectiveRate]         [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_EffectiveRate] DEFAULT (0) NULL,
    [OrigOrderQty]          [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_OrigOrderQty] DEFAULT (0) NULL,
    [BinNum]                VARCHAR (10)         NULL,
    [ConversionFactor]      [dbo].[pDec]         CONSTRAINT [DF__tblArHist__Conve__1D8A45D0] DEFAULT (1) NULL,
    [LottedYN]              BIT                  CONSTRAINT [DF__tblArHist__Lotte__1E7E6A09] DEFAULT (0) NULL,
    [InItemYN]              BIT                  CONSTRAINT [DF__tblArHist__InIte__1F728E42] DEFAULT (0) NULL,
    [HistSeqNum]            INT                  CONSTRAINT [DF__tblArHist__HistS__2066B27B] DEFAULT (0) NULL,
    [ExtCost]               [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_ExtCost] DEFAULT (0) NULL,
    [ExtFinalInc]           [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_ExtFinalInc] DEFAULT (0) NULL,
    [ExtOrigInc]            [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_ExtOrigInc] DEFAULT (0) NULL,
    [TransHistId]           VARCHAR (10)         NULL,
    [TaskId]                VARCHAR (10)         NULL,
    [PhaseName]             VARCHAR (30)         NULL,
    [ProjName]              VARCHAR (30)         NULL,
    [ExtFinalIncFgn]        [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_ExtFinalIncFgn] DEFAULT (0) NULL,
    [TaskName]              VARCHAR (30)         NULL,
    [Kit]                   BIT                  CONSTRAINT [DF__tblArHistDe__Kit__215AD6B4] DEFAULT (0) NULL,
    [ReqShipDate]           DATETIME             NULL,
    [PriceExt]              [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_PriceExt] DEFAULT ((0)) NULL,
    [PriceExtFgn]           [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_PriceExtFgn] DEFAULT ((0)) NULL,
    [CostExtFgn]            [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_CostExtFgn] DEFAULT ((0)) NULL,
    [CostExt]               [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_CostExt] DEFAULT ((0)) NULL,
    [BlanketDtlRef]         INT                  NULL,
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
    [UnitCommBasis]         [dbo].[pDec]         DEFAULT ((0)) NULL,
    [UnitCommBasisFgn]      [dbo].[pDec]         DEFAULT ((0)) NULL,
    [UnitPriceSellBasis]    [dbo].[pDec]         DEFAULT ((0)) NULL,
    [UnitPriceSellBasisFgn] [dbo].[pDec]         DEFAULT ((0)) NULL,
    [ZeroPrint]             BIT                  DEFAULT ((0)) NULL,
    [LineSeq]               INT                  NULL,
    [BOLNum]                VARCHAR (17)         NULL,
    [GrpId]                 INT                  NULL,
    [KitQty]                [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_KitQty] DEFAULT ((1)) NULL,
    [OriCompQty]            [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_OriCompQty] DEFAULT ((0)) NULL,
    [TotQtyOrdSell]         [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_TotQtyOrdSell] DEFAULT ((0)) NULL,
    [TotQtyShipSell]        [dbo].[pDec]         CONSTRAINT [DF_tblArHistDetail_TotQtyShipSell] DEFAULT ((0)) NULL,
    [Status]                TINYINT              CONSTRAINT [DF_tblArHistDetail_Status] DEFAULT ((0)) NULL,
    [ResCode]               VARCHAR (10)         NULL,
    [DropShipYn]            BIT                  CONSTRAINT [DF_tblArHistDetail_DropShipYn] DEFAULT ((0)) NOT NULL,
    [CF]                    XML                  NULL,
    [ActivityType]          TINYINT              NULL,
    [CustomerPartNumber]    [dbo].[pDescription] NULL,
    CONSTRAINT [PK_tblArHistDetail] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransID] ASC, [EntryNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblArHistDetail_TransID]
    ON [dbo].[tblArHistDetail]([TransID] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblArHistDetail] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArHistDetail] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblArHistDetail] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblArHistDetail] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistDetail';

