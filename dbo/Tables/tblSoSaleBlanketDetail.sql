CREATE TABLE [dbo].[tblSoSaleBlanketDetail] (
    [BlanketRef]         INT                  NOT NULL,
    [LineSeq]            INT                  NOT NULL,
    [LocId]              [dbo].[pLocID]       NULL,
    [ItemId]             [dbo].[pItemID]      NULL,
    [Descr]              [dbo].[pDescription] NULL,
    [LotNum]             [dbo].[pLotNum]      NULL,
    [AddnlDescr]         NVARCHAR (MAX)       NULL,
    [CatId]              NVARCHAR (2)         NULL,
    [TaxClass]           TINYINT              DEFAULT ((0)) NOT NULL,
    [AcctCode]           [dbo].[pGLAcctCode]  NULL,
    [GLAcctSales]        [dbo].[pGlAcct]      NULL,
    [GLAcctCOGS]         [dbo].[pGlAcct]      NULL,
    [GLAcctInv]          [dbo].[pGlAcct]      NULL,
    [PriceID]            NVARCHAR (10)        NULL,
    [PromoID]            NVARCHAR (10)        NULL,
    [QtyOrdered]         [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [QtyReleased]        [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [Units]              [dbo].[pUom]         NULL,
    [ConversionFactor]   [dbo].[pDec]         NOT NULL,
    [UnitPrice]          [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [PriceExt]           [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [UnitCost]           [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [CostExt]            [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [GrpId]              INT                  NULL,
    [Rep1Id]             [dbo].[pSalesRep]    NULL,
    [Rep1Pct]            [dbo].[pDec]         NULL,
    [Rep1CommRate]       [dbo].[pDec]         NULL,
    [Rep2Id]             [dbo].[pSalesRep]    NULL,
    [Rep2Pct]            [dbo].[pDec]         NULL,
    [Rep2CommRate]       [dbo].[pDec]         NULL,
    [UnitCommBasis]      [dbo].[pDec]         NULL,
    [ts]                 ROWVERSION           NULL,
    [CF]                 XML                  NULL,
    [_BlanketDtlRef]     INT                  NULL,
    [BlanketDtlRef]      INT                  NOT NULL,
    [CustomerPartNumber] [dbo].[pDescription] NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoSaleBlanketDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoSaleBlanketDetail';

