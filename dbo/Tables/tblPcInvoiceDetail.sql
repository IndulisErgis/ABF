CREATE TABLE [dbo].[tblPcInvoiceDetail] (
    [TransId]          [dbo].[pTransID]     NOT NULL,
    [EntryNum]         INT                  NOT NULL,
    [Descr]            [dbo].[pDescription] NULL,
    [AddnlDesc]        NVARCHAR (MAX)       NULL,
    [TaxClass]         TINYINT              NOT NULL,
    [Qty]              [dbo].[pDec]         CONSTRAINT [DF_tblPcInvoiceDetail_Qty] DEFAULT ((0)) NOT NULL,
    [ExtCostFgn]       [dbo].[pDec]         CONSTRAINT [DF_tblPcInvoiceDetail_ExtCostFgn] DEFAULT ((0)) NOT NULL,
    [ExtCost]          [dbo].[pDec]         CONSTRAINT [DF_tblPcInvoiceDetail_ExtCost] DEFAULT ((0)) NOT NULL,
    [ExtPriceFgn]      [dbo].[pDec]         CONSTRAINT [DF_tblPcInvoiceDetail_ExtPriceFgn] DEFAULT ((0)) NOT NULL,
    [ExtPrice]         [dbo].[pDec]         CONSTRAINT [DF_tblPcInvoiceDetail_ExtPrice] DEFAULT ((0)) NOT NULL,
    [UnitCommBasis]    [dbo].[pDec]         NULL,
    [UnitCommBasisFgn] [dbo].[pDec]         NULL,
    [Rep1Id]           [dbo].[pSalesRep]    NULL,
    [Rep1Pct]          [dbo].[pDec]         CONSTRAINT [DF_tblPcInvoiceDetail_Rep1Pct] DEFAULT ((0)) NOT NULL,
    [Rep2Id]           [dbo].[pSalesRep]    NULL,
    [Rep2Pct]          [dbo].[pDec]         CONSTRAINT [DF_tblPcInvoiceDetail_Rep2Pct] DEFAULT ((0)) NOT NULL,
    [Rep1CommRate]     [dbo].[pDec]         CONSTRAINT [DF_tblPcInvoiceDetail_Rep1CommRate] DEFAULT ((0)) NOT NULL,
    [Rep2CommRate]     [dbo].[pDec]         CONSTRAINT [DF_tblPcInvoiceDetail_Rep2CommRate] DEFAULT ((0)) NOT NULL,
    [ProjectDetailId]  INT                  NOT NULL,
    [ActivityId]       INT                  NOT NULL,
    [ZeroPrint]        BIT                  CONSTRAINT [DF_tblPcInvoiceDetail_ZeroPrint] DEFAULT ((0)) NOT NULL,
    [CatId]            NVARCHAR (2)         NULL,
    [LineSeq]          INT                  NOT NULL,
    [CF]               XML                  NULL,
    [ts]               ROWVERSION           NULL,
    CONSTRAINT [PK_tblPcInvoiceDetail] PRIMARY KEY CLUSTERED ([TransId] ASC, [EntryNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcInvoiceDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcInvoiceDetail';

