CREATE TABLE [dbo].[tblInItemLoc] (
    [ItemId]           [dbo].[pItemID]     NOT NULL,
    [LocId]            [dbo].[pLocID]      NOT NULL,
    [GLAcctCode]       [dbo].[pGLAcctCode] NULL,
    [ItemLocStatus]    TINYINT             CONSTRAINT [DF__tblInItem__ItemL__55B9905A] DEFAULT (1) NULL,
    [CostStd]          [dbo].[pDec]        CONSTRAINT [DF__tblInItem__CostS__56ADB493] DEFAULT (0) NULL,
    [CostAvg]          [dbo].[pDec]        CONSTRAINT [DF__tblInItem__CostA__57A1D8CC] DEFAULT (0) NULL,
    [CostBase]         [dbo].[pDec]        CONSTRAINT [DF__tblInItem__CostB__5895FD05] DEFAULT (0) NULL,
    [CostLast]         [dbo].[pDec]        CONSTRAINT [DF__tblInItem__CostL__598A213E] DEFAULT (0) NULL,
    [CarrCostPct]      [dbo].[pDec]        CONSTRAINT [DF__tblInItem__CarrC__5A7E4577] DEFAULT (0) NULL,
    [OrderCostAmt]     [dbo].[pDec]        CONSTRAINT [DF__tblInItem__Order__5B7269B0] DEFAULT (0) NULL,
    [QtySafetyStock]   [dbo].[pDec]        CONSTRAINT [DF__tblInItem__QtySa__5C668DE9] DEFAULT (0) NULL,
    [QtyOrderPoint]    [dbo].[pDec]        CONSTRAINT [DF__tblInItem__QtyOr__5D5AB222] DEFAULT (0) NULL,
    [QtyOnHandMax]     [dbo].[pDec]        CONSTRAINT [DF__tblInItem__QtyOn__5E4ED65B] DEFAULT (0) NULL,
    [QtyOrderMin]      [dbo].[pDec]        CONSTRAINT [DF__tblInItem__QtyOr__5F42FA94] DEFAULT (0) NULL,
    [Eoq]              [dbo].[pDec]        CONSTRAINT [DF__tblInItemLo__Eoq__60371ECD] DEFAULT (0) NULL,
    [EoqType]          TINYINT             CONSTRAINT [DF__tblInItem__EoqTy__612B4306] DEFAULT (0) NULL,
    [ForecastId]       VARCHAR (10)        NULL,
    [SafetyStockType]  TINYINT             CONSTRAINT [DF__tblInItem__Safet__621F673F] DEFAULT (0) NULL,
    [OrderPointType]   TINYINT             CONSTRAINT [DF__tblInItem__Order__63138B78] DEFAULT (0) NULL,
    [DateLastSale]     DATETIME            NULL,
    [DateLastPurch]    DATETIME            NULL,
    [DateLastSaleRet]  DATETIME            NULL,
    [DateLastPurchRet] DATETIME            NULL,
    [DateLastXfer]     DATETIME            NULL,
    [DateLastAdj]      DATETIME            NULL,
    [DateLastBuild]    DATETIME            NULL,
    [DateLastMatReq]   DATETIME            NULL,
    [DfltLeadTime]     [dbo].[pDec]        CONSTRAINT [DF__tblInItem__DfltL__6407AFB1] DEFAULT (0) NULL,
    [DfltBinNum]       VARCHAR (10)        NULL,
    [DfltVendId]       VARCHAR (10)        NULL,
    [DfltPriceId]      VARCHAR (10)        NULL,
    [PriceAdjType]     TINYINT             CONSTRAINT [DF__tblInItem__Price__64FBD3EA] DEFAULT (0) NULL,
    [PriceAdjBase]     TINYINT             CONSTRAINT [DF__tblInItem__Price__65EFF823] DEFAULT (0) NULL,
    [PriceAdjAmt]      [dbo].[pDec]        CONSTRAINT [DF__tblInItem__Price__66E41C5C] DEFAULT (0) NULL,
    [ts]               ROWVERSION          NULL,
    [ABCClass]         VARCHAR (10)        NULL,
    [CostLandedLast]   [dbo].[pDec]        DEFAULT ((0)) NULL,
    [OrderQtyUom]      [dbo].[pUom]        NULL,
    [CF]               XML                 NULL,
    CONSTRAINT [PK__tblInItemLoc__16644E42] PRIMARY KEY CLUSTERED ([ItemId] ASC, [LocId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItemLoc] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemLoc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItemLoc';

