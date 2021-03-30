CREATE TABLE [dbo].[tblSoTransHeader] (
    [TransId]            [dbo].[pTransID]    NOT NULL,
    [TransType]          SMALLINT            CONSTRAINT [DF__tblSoTran__Trans__53872F25] DEFAULT (9) NULL,
    [BatchId]            [dbo].[pBatchID]    CONSTRAINT [DF__tblSoTran__Batch__547B535E] DEFAULT ('######') NOT NULL,
    [LocId]              [dbo].[pLocID]      NULL,
    [CustId]             [dbo].[pCustID]     NULL,
    [CustLevel]          VARCHAR (10)        NULL,
    [ShipToID]           [dbo].[pCustID]     NULL,
    [ShipToName]         VARCHAR (30)        NULL,
    [ShipToAddr1]        VARCHAR (30)        NULL,
    [ShipToAddr2]        VARCHAR (60)        NULL,
    [ShipToCity]         VARCHAR (30)        NULL,
    [ShipToRegion]       VARCHAR (10)        NULL,
    [ShipToCountry]      [dbo].[pCountry]    NULL,
    [ShipToPostalCode]   VARCHAR (10)        NULL,
    [ShipVia]            VARCHAR (20)        NULL,
    [TermsCode]          [dbo].[pTermsCode]  NULL,
    [DistCode]           [dbo].[pDistCode]   NULL,
    [InvcNum]            [dbo].[pInvoiceNum] NULL,
    [InvcDate]           DATETIME            CONSTRAINT [DF__tblSoTran__InvcD__556F7797] DEFAULT (getdate()) NULL,
    [TransDate]          DATETIME            CONSTRAINT [DF__tblSoTran__Trans__56639BD0] DEFAULT (getdate()) NULL,
    [PODate]             DATETIME            CONSTRAINT [DF__tblSoTran__PODat__5757C009] DEFAULT (getdate()) NULL,
    [CustPONum]          VARCHAR (25)        NULL,
    [ShipNum]            NVARCHAR (30)       NULL,
    [ReqShipDate]        DATETIME            CONSTRAINT [DF__tblSoTran__ReqSh__584BE442] DEFAULT (getdate()) NULL,
    [ActShipDate]        DATETIME            NULL,
    [Rep1Id]             [dbo].[pSalesRep]   NULL,
    [Rep1Pct]            [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_Rep1Pct] DEFAULT (0) NULL,
    [Rep2Id]             [dbo].[pSalesRep]   NULL,
    [Rep2Pct]            [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_Rep2Pct] DEFAULT (0) NULL,
    [TaxableYN]          BIT                 CONSTRAINT [DF__tblSoTran__Taxab__5B2850ED] DEFAULT (1) NULL,
    [TaxOnFreight]       BIT                 CONSTRAINT [DF__tblSoTran__TaxOn__5C1C7526] DEFAULT (1) NULL,
    [TaxClassFreight]    TINYINT             CONSTRAINT [DF__tblSoTran__TaxCl__5D10995F] DEFAULT (0) NULL,
    [TaxClassMisc]       TINYINT             CONSTRAINT [DF__tblSoTran__TaxCl__5E04BD98] DEFAULT (0) NULL,
    [TaxGrpID]           [dbo].[pTaxLoc]     NULL,
    [TaxableSales]       [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_TaxableSales] DEFAULT (0) NULL,
    [NonTaxableSales]    [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_NonTaxableSales] DEFAULT (0) NULL,
    [SalesTax]           [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_SalesTax] DEFAULT (0) NULL,
    [Freight]            [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_Freight] DEFAULT (0) NULL,
    [Misc]               [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_Misc] DEFAULT (0) NULL,
    [TotCost]            [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_TotCost] DEFAULT (0) NULL,
    [CurrencyID]         [dbo].[pCurrency]   NULL,
    [ExchRate]           [dbo].[pDec]        CONSTRAINT [DF__tblSoTran__ExchR__65A5DF60] DEFAULT (1) NULL,
    [PickNum]            [dbo].[pInvoiceNum] NULL,
    [PostDate]           DATETIME            NULL,
    [GLPeriod]           SMALLINT            CONSTRAINT [DF__tblSoTran__GLPer__669A0399] DEFAULT (0) NULL,
    [FiscalYear]         SMALLINT            CONSTRAINT [DF__tblSoTran__Fisca__678E27D2] DEFAULT (0) NULL,
    [SumHistPeriod]      SMALLINT            CONSTRAINT [DF__tblSoTran__SumHi__68824C0B] DEFAULT (1) NULL,
    [PrintInvcStatus]    TINYINT             CONSTRAINT [DF__tblSoTran__Print__69767044] DEFAULT (0) NULL,
    [PrintPickStatus]    TINYINT             CONSTRAINT [DF__tblSoTran__Print__6A6A947D] DEFAULT (0) NULL,
    [NetDueDate]         DATETIME            NULL,
    [DiscDueDate]        DATETIME            NULL,
    [DiscAmt]            [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_DiscAmt] DEFAULT (0) NULL,
    [TaxAmtAdj]          [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_TaxAmtAdj] DEFAULT (0) NULL,
    [TaxAdj]             TINYINT             CONSTRAINT [DF__tblSoTran__TaxAd__6D470128] DEFAULT (1) NULL,
    [TaxLocAdj]          [dbo].[pTaxLoc]     NULL,
    [TaxClassAdj]        TINYINT             CONSTRAINT [DF__tblSoTran__TaxCl__6E3B2561] DEFAULT (0) NULL,
    [TaxableSalesFgn]    [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_TaxableSalesFgn] DEFAULT (0) NULL,
    [NonTaxableSalesFgn] [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_NonTaxableSalesFgn] DEFAULT (0) NULL,
    [SalesTaxFgn]        [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_SalesTaxFgn] DEFAULT (0) NULL,
    [FreightFgn]         [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_FreightFgn] DEFAULT (0) NULL,
    [MiscFgn]            [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_MiscFgn] DEFAULT (0) NULL,
    [TotCostFgn]         [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_TotCostFgn] DEFAULT (0) NULL,
    [TaxAmtAdjFgn]       [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_TaxAmtAdjFgn] DEFAULT (0) NULL,
    [ts]                 ROWVERSION          NULL,
    [OrgInvcNum]         [dbo].[pInvoiceNum] NULL,
    [PrintAcknowStatus]  TINYINT             CONSTRAINT [DF_tblSoTransHeader_PrintAcknowStatus] DEFAULT ((0)) NOT NULL,
    [PrintPackStatus]    TINYINT             CONSTRAINT [DF_tblSoTransHeader_PrintPackStatus] DEFAULT ((0)) NOT NULL,
    [PackNum]            [dbo].[pInvoiceNum] NULL,
    [ShipToPhone]        VARCHAR (24)        NULL,
    [Layaway]            BIT                 CONSTRAINT [DF__tblSoTran__Layaw__38623050] DEFAULT ((0)) NULL,
    [CalcGainLoss]       [dbo].[pDec]        DEFAULT ((0)) NULL,
    [OrgInvcExchRate]    [dbo].[pDec]        DEFAULT ((1)) NULL,
    [BlanketRef]         INT                 NULL,
    [Notes]              TEXT                NULL,
    [Rep1CommRate]       [dbo].[pDec]        DEFAULT ((0)) NULL,
    [Rep2CommRate]       [dbo].[pDec]        DEFAULT ((0)) NULL,
    [SoldToId]           [dbo].[pCustID]     NULL,
    [SourceId]           UNIQUEIDENTIFIER    CONSTRAINT [DF_tblSoTransHeader_SourceId] DEFAULT (newid()) NOT NULL,
    [VoidYn]             BIT                 CONSTRAINT [DF_tblSoTransHeader_VoidYn] DEFAULT ((0)) NOT NULL,
    [DiscAmtFgn]         [dbo].[pDec]        CONSTRAINT [DF_tblSoTransHeader_DiscAmtFgn] DEFAULT ((0)) NOT NULL,
    [CF]                 XML                 NULL,
    [ShipToAttn]         NVARCHAR (30)       NULL,
    [ShipMethod]         NVARCHAR (6)        NULL,
    [OrderState]         TINYINT             CONSTRAINT [DF_tblSoTransHeader_OrderState] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblSoTransHeader] PRIMARY KEY CLUSTERED ([TransId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSoTransHeader_VoidYn]
    ON [dbo].[tblSoTransHeader]([VoidYn] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlBatchId]
    ON [dbo].[tblSoTransHeader]([BatchId] ASC);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoTransHeader] TO [WebUserRole]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoTransHeader] TO [WebUserRole]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblSoTransHeader] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoTransHeader] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoTransHeader] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblSoTransHeader] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransHeader';

