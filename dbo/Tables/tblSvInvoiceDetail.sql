CREATE TABLE [dbo].[tblSvInvoiceDetail] (
    [TransID]               [dbo].[pTransID]     NOT NULL,
    [EntryNum]              INT                  NOT NULL,
    [LineSeq]               INT                  NOT NULL,
    [ResourceID]            NVARCHAR (24)        NULL,
    [LocID]                 [dbo].[pLocID]       NULL,
    [Description]           [dbo].[pDescription] NULL,
    [AdditionalDescription] NVARCHAR (MAX)       NULL,
    [TaxClass]              TINYINT              NOT NULL,
    [QtyEstimated]          [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [QtyUsed]               [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [Unit]                  NVARCHAR (5)         NULL,
    [UnitCostFgn]           [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [UnitPriceFgn]          [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [CostExtFgn]            [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [PriceExtFgn]           [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [UnitCommBasisFgn]      [dbo].[pDec]         NULL,
    [UnitCost]              [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [UnitPrice]             [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [CostExt]               [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [PriceExt]              [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [UnitCommBasis]         [dbo].[pDec]         NULL,
    [GLAcctCredit]          [dbo].[pGlAcct]      NULL,
    [GLAcctDebit]           [dbo].[pGlAcct]      NULL,
    [GLAcctSales]           [dbo].[pGlAcct]      NULL,
    [Rep1Id]                [dbo].[pSalesRep]    NULL,
    [Rep1Pct]               [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [Rep1CommRate]          [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [Rep2Id]                [dbo].[pSalesRep]    NULL,
    [Rep2Pct]               [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [Rep2CommRate]          [dbo].[pDec]         DEFAULT ((0)) NOT NULL,
    [WorkOrderTransID]      BIGINT               NULL,
    [WorkOrderTransType]    TINYINT              NULL,
    [DispatchID]            BIGINT               NULL,
    [CatID]                 NVARCHAR (2)         NULL,
    [CF]                    XML                  NULL,
    [ts]                    ROWVERSION           NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvInvoiceDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvInvoiceDetail';

