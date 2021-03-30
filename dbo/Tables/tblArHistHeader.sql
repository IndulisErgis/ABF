CREATE TABLE [dbo].[tblArHistHeader] (
    [PostRun]               [dbo].[pPostRun]    CONSTRAINT [DF__tblArHist__PostR__29F01CB5] DEFAULT (0) NOT NULL,
    [TransId]               [dbo].[pTransID]    NOT NULL,
    [TransType]             SMALLINT            CONSTRAINT [DF__tblArHist__Trans__2AE440EE] DEFAULT (1) NULL,
    [BatchId]               [dbo].[pBatchID]    CONSTRAINT [DF__tblArHist__Batch__2BD86527] DEFAULT ('######') NULL,
    [CustId]                [dbo].[pCustID]     NULL,
    [ShipToID]              VARCHAR (10)        NULL,
    [ShipToName]            VARCHAR (30)        NULL,
    [ShipToAddr1]           VARCHAR (30)        NULL,
    [ShipToAddr2]           VARCHAR (60)        NULL,
    [ShipToCity]            VARCHAR (30)        NULL,
    [ShipToRegion]          VARCHAR (10)        NULL,
    [ShipToCountry]         [dbo].[pCountry]    NULL,
    [ShipToPostalCode]      VARCHAR (10)        NULL,
    [ShipVia]               VARCHAR (20)        NULL,
    [TermsCode]             [dbo].[pTermsCode]  NULL,
    [TaxableYN]             BIT                 CONSTRAINT [DF__tblArHist__Taxab__2CCC8960] DEFAULT (1) NULL,
    [InvcNum]               [dbo].[pInvoiceNum] NULL,
    [WhseId]                [dbo].[pLocID]      NULL,
    [OrderDate]             DATETIME            NULL,
    [ShipNum]               NVARCHAR (30)       NULL,
    [ShipDate]              DATETIME            NULL,
    [InvcDate]              DATETIME            CONSTRAINT [DF__tblArHist__InvcD__2DC0AD99] DEFAULT (getdate()) NULL,
    [Rep1Id]                [dbo].[pSalesRep]   NULL,
    [Rep1Pct]               [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_Rep1Pct] DEFAULT (0) NULL,
    [Rep2Id]                [dbo].[pSalesRep]   NULL,
    [Rep2Pct]               [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_Rep2Pct] DEFAULT (0) NULL,
    [TaxOnFreight]          BIT                 CONSTRAINT [DF__tblArHist__TaxOn__309D1A44] DEFAULT (1) NULL,
    [TaxClassFreight]       TINYINT             CONSTRAINT [DF__tblArHist__TaxCl__31913E7D] DEFAULT (0) NULL,
    [TaxClassMisc]          TINYINT             CONSTRAINT [DF__tblArHist__TaxCl__328562B6] DEFAULT (0) NULL,
    [PostDate]              DATETIME            NULL,
    [FiscalYear]            SMALLINT            NULL,
    [GLPeriod]              SMALLINT            NULL,
    [TaxGrpID]              [dbo].[pTaxLoc]     NULL,
    [TaxSubtotal]           [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_TaxSubtotal] DEFAULT (0) NULL,
    [NonTaxSubtotal]        [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_NonTaxSubtotal] DEFAULT (0) NULL,
    [SalesTax]              [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_SalesTax] DEFAULT (0) NULL,
    [Freight]               [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_Freight] DEFAULT (0) NULL,
    [Misc]                  [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_Misc] DEFAULT (0) NULL,
    [TotCost]               [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_TotCost] DEFAULT (0) NULL,
    [TotPmtAmt]             [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_TotPmtAmt] DEFAULT (0) NULL,
    [TaxSubtotalFgn]        [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_TaxSubtotalFgn] DEFAULT (0) NULL,
    [NonTaxSubtotalFgn]     [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_NonTaxSubtotalFgn] DEFAULT (0) NULL,
    [SalesTaxFgn]           [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_SalesTaxFgn] DEFAULT (0) NULL,
    [FreightFgn]            [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_FreightFgn] DEFAULT (0) NULL,
    [MiscFgn]               [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_MiscFgn] DEFAULT (0) NULL,
    [TotCostFgn]            [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_TotCostFgn] DEFAULT (0) NULL,
    [TotPmtAmtFgn]          [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_TotPmtAmtFgn] DEFAULT (0) NULL,
    [PrintStatus]           TINYINT             CONSTRAINT [DF__tblArHist__Print__42BBCA7F] DEFAULT (0) NULL,
    [CustPONum]             VARCHAR (25)        NULL,
    [DistCode]              [dbo].[pDistCode]   NULL,
    [CurrencyID]            [dbo].[pCurrency]   NULL,
    [ExchRate]              [dbo].[pDec]        CONSTRAINT [DF__tblArHist__ExchR__43AFEEB8] DEFAULT (1) NULL,
    [DiscDueDate]           DATETIME            NULL,
    [NetDueDate]            DATETIME            NULL,
    [DiscAmt]               [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_DiscAmt] DEFAULT (0) NULL,
    [DiscAmtFgn]            [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_DiscAmtFgn] DEFAULT (0) NULL,
    [SumHistPeriod]         SMALLINT            CONSTRAINT [DF__tblArHist__SumHi__4598372A] DEFAULT (1) NULL,
    [TaxAmtAdj]             [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_TaxAmtAdj] DEFAULT (0) NULL,
    [TaxAmtAdjFgn]          [dbo].[pDec]        CONSTRAINT [DF_tblArHistHeader_TaxAmtAdjFgn] DEFAULT (0) NULL,
    [TaxAdj]                TINYINT             CONSTRAINT [DF__tblArHist__TaxAd__4874A3D5] DEFAULT (1) NULL,
    [TaxLocAdj]             VARCHAR (10)        NULL,
    [TaxClassAdj]           TINYINT             CONSTRAINT [DF__tblArHist__TaxCl__4968C80E] DEFAULT (0) NULL,
    [CustLevel]             VARCHAR (10)        NULL,
    [PODate]                DATETIME            NULL,
    [ReqShipDate]           DATETIME            NULL,
    [PickNum]               VARCHAR (15)        NULL,
    [Source]                TINYINT             CONSTRAINT [DF__tblArHist__Sourc__4A5CEC47] DEFAULT (0) NULL,
    [BillingPeriodFrom]     DATETIME            NULL,
    [PMTransType]           VARCHAR (4)         NULL,
    [ProjItem]              VARCHAR (4)         NULL,
    [BillingPeriodThru]     DATETIME            NULL,
    [BillingFormat]         SMALLINT            NULL,
    [CredMemNum]            [dbo].[pInvoiceNum] NULL,
    [PackNum]               [dbo].[pInvoiceNum] NULL,
    [CalcGainLoss]          [dbo].[pDec]        DEFAULT ((0)) NULL,
    [TotPmtGainLoss]        [dbo].[pDec]        DEFAULT ((0)) NULL,
    [BlanketRef]            INT                 NULL,
    [Rep1CommRate]          [dbo].[pDec]        DEFAULT ((0)) NULL,
    [Rep2CommRate]          [dbo].[pDec]        DEFAULT ((0)) NULL,
    [SoldToId]              [dbo].[pCustID]     NULL,
    [SourceInfo]            VARCHAR (15)        NULL,
    [SourceId]              UNIQUEIDENTIFIER    NOT NULL,
    [Notes]                 TEXT                NULL,
    [ShipToPhone]           VARCHAR (24)        NULL,
    [ReturnDirectToStockYn] BIT                 CONSTRAINT [DF_tblArHistHeader_ReturnDirectToStockYn] DEFAULT ((1)) NOT NULL,
    [GLAcctReceivables]     [dbo].[pGlAcct]     NULL,
    [GLAcctSalesTax]        [dbo].[pGlAcct]     NULL,
    [GLAcctFreight]         [dbo].[pGlAcct]     NULL,
    [GLAcctMisc]            [dbo].[pGlAcct]     NULL,
    [GlAcctGainLoss]        [dbo].[pGlAcct]     NULL,
    [VoidYn]                BIT                 CONSTRAINT [DF_tblArHistHeader_VoidYn] DEFAULT ((0)) NOT NULL,
    [CF]                    XML                 NULL,
    [PrintOption]           NVARCHAR (255)      NULL,
    [ShipToAttn]            NVARCHAR (30)       NULL,
    [ShipMethod]            NVARCHAR (6)        NULL,
    [HistID]                BIGINT              IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK__tblArHistHeader__28FBF87C] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblArHistHeader_InvcNum_TransId_CustId]
    ON [dbo].[tblArHistHeader]([InvcNum] ASC, [TransId] ASC, [CustId] ASC);


GO
CREATE NONCLUSTERED INDEX [FiscalYr_Period]
    ON [dbo].[tblArHistHeader]([FiscalYear] ASC, [GLPeriod] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [InvcDate]
    ON [dbo].[tblArHistHeader]([InvcDate] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_tblArHistHeader_SourceID]
    ON [dbo].[tblArHistHeader]([SourceId] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlCustId]
    ON [dbo].[tblArHistHeader]([CustId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArHistHeader] TO [WebUserRole]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblArHistHeader] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArHistHeader] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblArHistHeader] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblArHistHeader] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistHeader';

