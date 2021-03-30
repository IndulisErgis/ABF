CREATE TABLE [dbo].[tblApRecurHeader] (
    [RecurID]         VARCHAR (10)        NOT NULL,
    [VendorID]        [dbo].[pVendorID]   NOT NULL,
    [InvoiceNum]      [dbo].[pInvoiceNum] NULL,
    [PONum]           VARCHAR (25)        NULL,
    [DistCode]        [dbo].[pDistCode]   NULL,
    [TermsCode]       [dbo].[pTermsCode]  NULL,
    [Subtotal]        [dbo].[pDec]        CONSTRAINT [DF__tblApRecu__Subto__585605E3] DEFAULT (0) NULL,
    [SalesTax]        [dbo].[pDec]        CONSTRAINT [DF__tblApRecu__Sales__594A2A1C] DEFAULT (0) NULL,
    [Freight]         [dbo].[pDec]        CONSTRAINT [DF__tblApRecu__Freig__5A3E4E55] DEFAULT (0) NULL,
    [Misc]            [dbo].[pDec]        CONSTRAINT [DF__tblApRecur__Misc__5B32728E] DEFAULT (0) NULL,
    [CurrencyId]      [dbo].[pCurrency]   NOT NULL,
    [ExchRate]        [dbo].[pDec]        CONSTRAINT [DF__tblApRecu__ExchR__5C2696C7] DEFAULT (1) NULL,
    [ExchRateDate]    DATETIME            CONSTRAINT [DF__tblApRecu__ExchR__5D1ABB00] DEFAULT (getdate()) NULL,
    [UseCurrExchRate] BIT                 CONSTRAINT [DF__tblApRecu__UseCu__5E0EDF39] DEFAULT (0) NULL,
    [SubtotalFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblApRecu__Subto__5F030372] DEFAULT (0) NULL,
    [SalesTaxFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblApRecu__Sales__5FF727AB] DEFAULT (0) NULL,
    [FreightFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApRecu__Freig__60EB4BE4] DEFAULT (0) NULL,
    [MiscFgn]         [dbo].[pDec]        CONSTRAINT [DF__tblApRecu__MiscF__61DF701D] DEFAULT (0) NULL,
    [RunCode]         VARCHAR (6)         NOT NULL,
    [Ten99InvoiceYN]  BIT                 CONSTRAINT [DF__tblApRecu__Ten99__62D39456] DEFAULT (0) NULL,
    [StartingDate]    DATETIME            CONSTRAINT [DF__tblApRecu__Start__63C7B88F] DEFAULT (getdate()) NULL,
    [EndingDate]      DATETIME            NULL,
    [StartingBal]     [dbo].[pDec]        CONSTRAINT [DF__tblApRecu__Start__65B00101] DEFAULT (0) NULL,
    [RemainingBal]    [dbo].[pDec]        CONSTRAINT [DF__tblApRecu__Remai__66A4253A] DEFAULT (0) NULL,
    [NumOfPmt]        SMALLINT            CONSTRAINT [DF__tblApRecu__NumOf__67984973] DEFAULT (0) NULL,
    [RemainingPmt]    SMALLINT            CONSTRAINT [DF__tblApRecu__Remai__688C6DAC] DEFAULT (0) NULL,
    [Notes]           TEXT                NULL,
    [ts]              ROWVERSION          NULL,
    [TaxGrpID]        [dbo].[pTaxLoc]     NULL,
    [TaxClassFreight] TINYINT             CONSTRAINT [DF_tblApRecurHeader_TaxClassFreight] DEFAULT (0) NULL,
    [TaxClassMisc]    TINYINT             CONSTRAINT [DF_tblApRecurHeader_TaxClassMisc] DEFAULT (0) NULL,
    [TaxableYn]       BIT                 CONSTRAINT [DF_tblApRecurHeader_TaxableYn] DEFAULT (1) NULL,
    [BillInterval]    INT                 DEFAULT ((0)) NULL,
    [BillType]        TINYINT             DEFAULT ((0)) NOT NULL,
    [LastBillDate]    DATETIME            NULL,
    [NextBillDate]    DATETIME            NULL,
    [CF]              XML                 NULL,
    CONSTRAINT [PK__tblApRecurHeader__0C1BC9F9] PRIMARY KEY CLUSTERED ([RecurID] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApRecurHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApRecurHeader';

