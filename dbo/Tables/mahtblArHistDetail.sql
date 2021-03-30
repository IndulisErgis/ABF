﻿CREATE TABLE [dbo].[mahtblArHistDetail] (
    [PostRun]               VARCHAR (14)     NOT NULL,
    [TransID]               VARCHAR (8)      NOT NULL,
    [EntryNum]              INT              NOT NULL,
    [ItemJob]               TINYINT          NULL,
    [WhseId]                VARCHAR (10)     NULL,
    [PartId]                VARCHAR (24)     NULL,
    [JobId]                 VARCHAR (10)     NULL,
    [PhaseId]               VARCHAR (10)     NULL,
    [JobCompleteYN]         BIT              NULL,
    [PartType]              TINYINT          NULL,
    [Desc]                  NVARCHAR (255)   NULL,
    [AddnlDesc]             TEXT             NULL,
    [CatId]                 VARCHAR (2)      NULL,
    [TaxClass]              TINYINT          NOT NULL,
    [AcctCode]              VARCHAR (6)      NULL,
    [GLAcctSales]           VARCHAR (40)     NULL,
    [GLAcctCOGS]            VARCHAR (40)     NULL,
    [GLAcctInv]             VARCHAR (40)     NULL,
    [QtyOrdSell]            DECIMAL (20, 10) NULL,
    [UnitsSell]             VARCHAR (5)      NULL,
    [UnitsBase]             VARCHAR (5)      NULL,
    [QtyShipSell]           DECIMAL (20, 10) NULL,
    [QtyShipBase]           DECIMAL (20, 10) NULL,
    [QtyBackordSell]        DECIMAL (20, 10) NULL,
    [PriceID]               VARCHAR (10)     NULL,
    [UnitPriceSell]         DECIMAL (20, 10) NULL,
    [UnitPriceSellFgn]      DECIMAL (20, 10) NULL,
    [UnitCostSell]          DECIMAL (20, 10) NULL,
    [UnitCostSellFgn]       DECIMAL (20, 10) NULL,
    [PromoID]               VARCHAR (10)     NULL,
    [ActShipDate]           DATETIME         NULL,
    [EffectiveRate]         DECIMAL (20, 10) NULL,
    [OrigOrderQty]          DECIMAL (20, 10) NULL,
    [BinNum]                VARCHAR (10)     NULL,
    [ConversionFactor]      DECIMAL (20, 10) NULL,
    [LottedYN]              BIT              NULL,
    [InItemYN]              BIT              NULL,
    [HistSeqNum]            INT              NULL,
    [ExtCost]               DECIMAL (20, 10) NULL,
    [ExtFinalInc]           DECIMAL (20, 10) NULL,
    [ExtOrigInc]            DECIMAL (20, 10) NULL,
    [TransHistId]           VARCHAR (10)     NULL,
    [TaskId]                VARCHAR (10)     NULL,
    [PhaseName]             VARCHAR (30)     NULL,
    [ProjName]              VARCHAR (30)     NULL,
    [ExtFinalIncFgn]        DECIMAL (20, 10) NULL,
    [TaskName]              VARCHAR (30)     NULL,
    [Kit]                   BIT              NULL,
    [ReqShipDate]           DATETIME         NULL,
    [PriceExt]              DECIMAL (20, 10) NULL,
    [PriceExtFgn]           DECIMAL (20, 10) NULL,
    [CostExtFgn]            DECIMAL (20, 10) NULL,
    [CostExt]               DECIMAL (20, 10) NULL,
    [BlanketDtlRef]         INT              NULL,
    [PriceAdjAmt]           DECIMAL (20, 10) NULL,
    [PriceAdjAmtFgn]        DECIMAL (20, 10) NULL,
    [PriceAdjPct]           DECIMAL (20, 10) NULL,
    [PriceAdjType]          TINYINT          NULL,
    [Rep1CommRate]          DECIMAL (20, 10) NULL,
    [Rep1Id]                VARCHAR (3)      NULL,
    [Rep1Pct]               DECIMAL (20, 10) NULL,
    [Rep2CommRate]          DECIMAL (20, 10) NULL,
    [Rep2Id]                VARCHAR (3)      NULL,
    [Rep2Pct]               DECIMAL (20, 10) NULL,
    [UnitCommBasis]         DECIMAL (20, 10) NULL,
    [UnitCommBasisFgn]      DECIMAL (20, 10) NULL,
    [UnitPriceSellBasis]    DECIMAL (20, 10) NULL,
    [UnitPriceSellBasisFgn] DECIMAL (20, 10) NULL,
    [ZeroPrint]             BIT              NULL,
    [LineSeq]               INT              NULL,
    [BOLNum]                VARCHAR (17)     NULL,
    [GrpId]                 INT              NULL,
    [KitQty]                DECIMAL (20, 10) NULL,
    [OriCompQty]            DECIMAL (20, 10) NULL,
    [TotQtyOrdSell]         DECIMAL (20, 10) NULL,
    [TotQtyShipSell]        DECIMAL (20, 10) NULL,
    [Status]                TINYINT          NULL,
    [ResCode]               VARCHAR (10)     NULL,
    [DropShipYn]            BIT              NOT NULL,
    [CF]                    XML              NULL,
    [ActivityType]          TINYINT          NULL
);
