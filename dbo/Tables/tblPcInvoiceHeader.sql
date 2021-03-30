CREATE TABLE [dbo].[tblPcInvoiceHeader] (
    [TransId]           [dbo].[pTransID]    NOT NULL,
    [TransType]         SMALLINT            NOT NULL,
    [VoidYn]            BIT                 CONSTRAINT [DF_tblPcInvoiceHeader_VoidYn] DEFAULT ((0)) NOT NULL,
    [BatchId]           [dbo].[pBatchID]    CONSTRAINT [DF_tblPcInvoiceHeader_BatchId] DEFAULT ('######') NOT NULL,
    [CustId]            [dbo].[pCustID]     NOT NULL,
    [TermsCode]         [dbo].[pTermsCode]  NOT NULL,
    [TaxableYN]         BIT                 NOT NULL,
    [InvcNum]           [dbo].[pInvoiceNum] NULL,
    [OrgInvcNum]        [dbo].[pInvoiceNum] NULL,
    [OrgInvcExchRate]   [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_OrgInvcExchRate] DEFAULT ((1)) NOT NULL,
    [LocId]             [dbo].[pLocID]      NULL,
    [OrderDate]         DATETIME            NULL,
    [InvcDate]          DATETIME            NOT NULL,
    [Rep1Id]            [dbo].[pSalesRep]   NULL,
    [Rep1Pct]           [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_Rep1Pct] DEFAULT ((0)) NOT NULL,
    [Rep2Id]            [dbo].[pSalesRep]   NULL,
    [Rep2Pct]           [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_Rep2Pct] DEFAULT ((0)) NOT NULL,
    [FiscalPeriod]      SMALLINT            CONSTRAINT [DF_tblPcInvoiceHeader_FiscalPeriod] DEFAULT ((0)) NOT NULL,
    [FiscalYear]        SMALLINT            CONSTRAINT [DF_tblPcInvoiceHeader_FiscalYear] DEFAULT ((0)) NOT NULL,
    [TaxGrpID]          [dbo].[pTaxLoc]     NOT NULL,
    [TaxSubtotalFgn]    [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_TaxSubtotalFgn] DEFAULT ((0)) NOT NULL,
    [NonTaxSubtotalFgn] [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_NonTaxSubtotalFgn] DEFAULT ((0)) NOT NULL,
    [SalesTaxFgn]       [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_SalesTaxFgn] DEFAULT ((0)) NOT NULL,
    [TotCostFgn]        [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_TotCostFgn] DEFAULT ((0)) NOT NULL,
    [TaxSubtotal]       [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_TaxSubtotal] DEFAULT ((0)) NOT NULL,
    [NonTaxSubtotal]    [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_NonTaxSubtotal] DEFAULT ((0)) NOT NULL,
    [SalesTax]          [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_SalesTax] DEFAULT ((0)) NOT NULL,
    [TotCost]           [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_TotCost] DEFAULT ((0)) NOT NULL,
    [PrintStatus]       TINYINT             CONSTRAINT [DF_tblPcInvoiceHeader_PrintStatus] DEFAULT ((0)) NOT NULL,
    [CustPONum]         NVARCHAR (25)       NULL,
    [DistCode]          [dbo].[pDistCode]   NOT NULL,
    [CurrencyID]        [dbo].[pCurrency]   NOT NULL,
    [ExchRate]          [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_ExchRate] DEFAULT ((1)) NOT NULL,
    [CalcGainLoss]      [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_CalcGainLoss] DEFAULT ((0)) NOT NULL,
    [DiscDueDate]       DATETIME            NULL,
    [NetDueDate]        DATETIME            NULL,
    [DiscAmtFgn]        [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_DiscAmtFgn] DEFAULT ((0)) NULL,
    [TaxAmtAdjFgn]      [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_TaxAmtAdjFgn] DEFAULT ((0)) NOT NULL,
    [DiscAmt]           [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_DiscAmt] DEFAULT ((0)) NULL,
    [TaxAmtAdj]         [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_TaxAmtAdj] DEFAULT ((0)) NOT NULL,
    [TaxLocAdj]         [dbo].[pTaxLoc]     NULL,
    [TaxClassAdj]       TINYINT             CONSTRAINT [DF_tblPcInvoiceHeader_TaxClassAdj] DEFAULT ((0)) NULL,
    [Rep1CommRate]      [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_Rep1CommRate] DEFAULT ((0)) NOT NULL,
    [Rep2CommRate]      [dbo].[pDec]        CONSTRAINT [DF_tblPcInvoiceHeader_Rep2CommRate] DEFAULT ((0)) NOT NULL,
    [SourceId]          UNIQUEIDENTIFIER    NOT NULL,
    [PrintOption]       NVARCHAR (255)      NULL,
    [HoldYn]            BIT                 CONSTRAINT [DF_tblPcInvoiceHeader_HoldYn] DEFAULT ((0)) NOT NULL,
    [CF]                XML                 NULL,
    [ts]                ROWVERSION          NULL,
    CONSTRAINT [PK_tblPcInvoiceHeader] PRIMARY KEY CLUSTERED ([TransId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlBatchId]
    ON [dbo].[tblPcInvoiceHeader]([BatchId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcInvoiceHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcInvoiceHeader';

