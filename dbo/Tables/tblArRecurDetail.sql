CREATE TABLE [dbo].[tblArRecurDetail] (
    [RecurId]            VARCHAR (8)          NOT NULL,
    [EntryNum]           INT                  NOT NULL,
    [LocId]              [dbo].[pLocID]       NULL,
    [ItemId]             [dbo].[pItemID]      NULL,
    [Descr]              [dbo].[pDescription] NULL,
    [CatId]              VARCHAR (2)          NULL,
    [TaxClass]           TINYINT              CONSTRAINT [DF_tblArRecurDetail_TaxClass] DEFAULT ((0)) NOT NULL,
    [PriceId]            VARCHAR (10)         NULL,
    [PromoId]            VARCHAR (10)         NULL,
    [AcctCode]           [dbo].[pGLAcctCode]  NULL,
    [GLAcctSales]        [dbo].[pGlAcct]      NULL,
    [GLAcctCOGS]         [dbo].[pGlAcct]      NULL,
    [GLAcctInv]          [dbo].[pGlAcct]      NULL,
    [Quantity]           [dbo].[pDec]         CONSTRAINT [DF_tblArRecurDetail_Quantity] DEFAULT ((0)) NOT NULL,
    [Units]              [dbo].[pUom]         NULL,
    [UnitPrice]          [dbo].[pDec]         CONSTRAINT [DF_tblArRecurDetail_UnitPrice] DEFAULT ((0)) NOT NULL,
    [UnitCost]           [dbo].[pDec]         CONSTRAINT [DF_tblArRecurDetail_UnitCost] DEFAULT ((0)) NOT NULL,
    [Rep1Id]             [dbo].[pSalesRep]    NULL,
    [Rep1Pct]            [dbo].[pDec]         CONSTRAINT [DF_tblArRecurDetail_Rep1Pct] DEFAULT ((0)) NOT NULL,
    [Rep2Id]             [dbo].[pSalesRep]    NULL,
    [Rep2Pct]            [dbo].[pDec]         CONSTRAINT [DF_tblArRecurDetail_Rep2Pct] DEFAULT ((0)) NOT NULL,
    [UnitCommBasis]      [dbo].[pDec]         CONSTRAINT [DF_tblArRecurDetail_UnitCommBasis] DEFAULT ((0)) NULL,
    [AddnlDescr]         TEXT                 NULL,
    [CF]                 XML                  NULL,
    [ts]                 ROWVERSION           NULL,
    [LineSeq]            INT                  NULL,
    [CustomerPartNumber] [dbo].[pDescription] NULL,
    CONSTRAINT [PK_tblArRecurDetail] PRIMARY KEY CLUSTERED ([RecurId] ASC, [EntryNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArRecurDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArRecurDetail';

