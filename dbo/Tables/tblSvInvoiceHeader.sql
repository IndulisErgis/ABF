CREATE TABLE [dbo].[tblSvInvoiceHeader] (
    [TransID]           [dbo].[pTransID]    NOT NULL,
    [TransType]         SMALLINT            NOT NULL,
    [VoidYN]            BIT                 DEFAULT ((0)) NOT NULL,
    [BatchID]           [dbo].[pBatchID]    NOT NULL,
    [CustID]            [dbo].[pCustID]     NOT NULL,
    [BillToID]          [dbo].[pCustID]     NOT NULL,
    [TermsCode]         [dbo].[pTermsCode]  NOT NULL,
    [DistCode]          [dbo].[pDistCode]   NOT NULL,
    [TaxableYN]         BIT                 DEFAULT ((1)) NOT NULL,
    [InvoiceNumber]     [dbo].[pInvoiceNum] NULL,
    [InvoiceDate]       DATETIME            NULL,
    [CustomerPoNumber]  NVARCHAR (25)       NULL,
    [PODate]            DATETIME            NULL,
    [WorkOrderNo]       [dbo].[pTransID]    NOT NULL,
    [OrderDate]         DATETIME            NOT NULL,
    [CompletedDate]     DATETIME            NULL,
    [DiscDueDate]       DATETIME            NULL,
    [NetDueDate]        DATETIME            NULL,
    [FiscalYear]        SMALLINT            NOT NULL,
    [FiscalPeriod]      SMALLINT            NOT NULL,
    [Rep1Id]            [dbo].[pSalesRep]   NULL,
    [Rep1Pct]           [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [Rep1CommRate]      [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [Rep2Id]            [dbo].[pSalesRep]   NULL,
    [Rep2Pct]           [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [Rep2CommRate]      [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [TaxGrpID]          [dbo].[pTaxLoc]     NOT NULL,
    [TaxLocAdj]         [dbo].[pTaxLoc]     NULL,
    [TaxClassAdj]       TINYINT             NULL,
    [TaxSubtotalFgn]    [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [NonTaxSubtotalFgn] [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [SalesTaxFgn]       [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [TotCostFgn]        [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [TotPmtAmtFgn]      [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [DiscAmtFgn]        [dbo].[pDec]        DEFAULT ((0)) NULL,
    [TaxAmtAdjFgn]      [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [TaxSubtotal]       [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [NonTaxSubtotal]    [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [SalesTax]          [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [TotCost]           [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [TotPmtAmt]         [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [DiscAmt]           [dbo].[pDec]        DEFAULT ((0)) NULL,
    [TaxAmtAdj]         [dbo].[pDec]        DEFAULT ((0)) NOT NULL,
    [BillingFormat]     NVARCHAR (255)      NULL,
    [CurrencyID]        [dbo].[pCurrency]   NOT NULL,
    [ExchRate]          [dbo].[pDec]        DEFAULT ((1)) NOT NULL,
    [HoldYN]            BIT                 DEFAULT ((0)) NOT NULL,
    [SourceId]          UNIQUEIDENTIFIER    NOT NULL,
    [WorkOrderID]       BIGINT              NOT NULL,
    [PrintStatus]       TINYINT             DEFAULT ((0)) NOT NULL,
    [CF]                XML                 NULL,
    [ts]                ROWVERSION          NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvInvoiceHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSvInvoiceHeader';

