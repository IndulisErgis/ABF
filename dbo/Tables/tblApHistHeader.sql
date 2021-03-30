CREATE TABLE [dbo].[tblApHistHeader] (
    [PostRun]         [dbo].[pPostRun]    CONSTRAINT [DF__tblApHist__PostR__29D02124] DEFAULT (0) NOT NULL,
    [TransId]         [dbo].[pTransID]    NOT NULL,
    [InvoiceNum]      [dbo].[pInvoiceNum] NOT NULL,
    [BatchId]         [dbo].[pBatchID]    CONSTRAINT [DF__tblApHist__Batch__2AC4455D] DEFAULT ('######') NULL,
    [WhseId]          [dbo].[pLocID]      NULL,
    [VendorId]        [dbo].[pVendorID]   NULL,
    [InvoiceDate]     DATETIME            CONSTRAINT [DF__tblApHist__Invoi__2BB86996] DEFAULT (getdate()) NULL,
    [TransType]       SMALLINT            CONSTRAINT [DF__tblApHist__Trans__2CAC8DCF] DEFAULT (1) NULL,
    [PONum]           VARCHAR (25)        NULL,
    [DistCode]        [dbo].[pDistCode]   NULL,
    [TermsCode]       [dbo].[pTermsCode]  NULL,
    [DueDate1]        DATETIME            NULL,
    [DueDate2]        DATETIME            NULL,
    [DueDate3]        DATETIME            NULL,
    [PmtAmt1]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__PmtAm__2DA0B208] DEFAULT (0) NULL,
    [PmtAmt2]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__PmtAm__2E94D641] DEFAULT (0) NULL,
    [PmtAmt3]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__PmtAm__2F88FA7A] DEFAULT (0) NULL,
    [Subtotal]        [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Subto__307D1EB3] DEFAULT (0) NULL,
    [SalesTax]        [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Sales__317142EC] DEFAULT (0) NULL,
    [Freight]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Freig__32656725] DEFAULT (0) NULL,
    [Misc]            [dbo].[pDec]        CONSTRAINT [DF__tblApHistH__Misc__33598B5E] DEFAULT (0) NULL,
    [CashDisc]        [dbo].[pDec]        CONSTRAINT [DF__tblApHist__CashD__344DAF97] DEFAULT (0) NULL,
    [PrepaidAmt]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Prepa__3541D3D0] DEFAULT (0) NULL,
    [CurrencyId]      [dbo].[pCurrency]   NULL,
    [ExchRate]        [dbo].[pDec]        CONSTRAINT [DF__tblApHist__ExchR__3635F809] DEFAULT (1) NULL,
    [PmtAmt1Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__PmtAm__372A1C42] DEFAULT (0) NULL,
    [PmtAmt2Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__PmtAm__381E407B] DEFAULT (0) NULL,
    [PmtAmt3Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__PmtAm__391264B4] DEFAULT (0) NULL,
    [SubtotalFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Subto__3A0688ED] DEFAULT (0) NULL,
    [SalesTaxFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Sales__3AFAAD26] DEFAULT (0) NULL,
    [FreightFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Freig__3BEED15F] DEFAULT (0) NULL,
    [MiscFgn]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__MiscF__3CE2F598] DEFAULT (0) NULL,
    [CashDiscFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblApHist__CashD__3DD719D1] DEFAULT (0) NULL,
    [PrepaidAmtFgn]   [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Prepa__3ECB3E0A] DEFAULT (0) NULL,
    [CheckNum]        VARCHAR (50)        NULL,
    [CheckDate]       DATETIME            NULL,
    [PostDate]        DATETIME            NULL,
    [GLPeriod]        SMALLINT            CONSTRAINT [DF__tblApHist__GLPer__3FBF6243] DEFAULT (0) NULL,
    [FiscalYear]      SMALLINT            CONSTRAINT [DF__tblApHist__Fisca__40B3867C] DEFAULT (0) NULL,
    [Ten99InvoiceYN]  BIT                 NULL,
    [Status]          TINYINT             CONSTRAINT [DF__tblApHist__Statu__41A7AAB5] DEFAULT (0) NULL,
    [Notes]           TEXT                NULL,
    [TaxGrpID]        [dbo].[pTaxLoc]     NULL,
    [TaxableYn]       BIT                 CONSTRAINT [DF__tblApHist__Taxab__429BCEEE] DEFAULT (1) NULL,
    [Taxable]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Taxab__438FF327] DEFAULT (0) NULL,
    [NonTaxable]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__NonTa__44841760] DEFAULT (0) NULL,
    [TaxableFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__Taxab__45783B99] DEFAULT (0) NULL,
    [NonTaxableFgn]   [dbo].[pDec]        CONSTRAINT [DF__tblApHist__NonTa__466C5FD2] DEFAULT (0) NULL,
    [TaxClassFreight] TINYINT             CONSTRAINT [DF__tblApHist__TaxCl__4760840B] DEFAULT (0) NULL,
    [TaxClassMisc]    TINYINT             CONSTRAINT [DF__tblApHist__TaxCl__4854A844] DEFAULT (0) NULL,
    [TaxLocID1]       [dbo].[pTaxLoc]     NULL,
    [TaxAmt1]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__4948CC7D] DEFAULT (0) NULL,
    [TaxAmt1Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__4A3CF0B6] DEFAULT (0) NULL,
    [TaxLocID2]       [dbo].[pTaxLoc]     NULL,
    [TaxAmt2]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__4B3114EF] DEFAULT (0) NULL,
    [TaxAmt2Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__4C253928] DEFAULT (0) NULL,
    [TaxLocID3]       [dbo].[pTaxLoc]     NULL,
    [TaxAmt3]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__4D195D61] DEFAULT (0) NULL,
    [TaxAmt3Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__4E0D819A] DEFAULT (0) NULL,
    [TaxLocID4]       [dbo].[pTaxLoc]     NULL,
    [TaxAmt4]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__4F01A5D3] DEFAULT (0) NULL,
    [TaxAmt4Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__4FF5CA0C] DEFAULT (0) NULL,
    [TaxLocID5]       [dbo].[pTaxLoc]     NULL,
    [TaxAmt5]         [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__50E9EE45] DEFAULT (0) NULL,
    [TaxAmt5Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAm__51DE127E] DEFAULT (0) NULL,
    [TaxAdjClass]     TINYINT             CONSTRAINT [DF__tblApHist__TaxAd__52D236B7] DEFAULT (0) NULL,
    [TaxAdjLocID]     [dbo].[pTaxLoc]     NULL,
    [TaxAdjAmt]       [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAd__53C65AF0] DEFAULT (0) NULL,
    [TaxAdjAmtFgn]    [dbo].[pDec]        CONSTRAINT [DF__tblApHist__TaxAd__54BA7F29] DEFAULT (0) NULL,
    [Source]          TINYINT             CONSTRAINT [DF__tblApHist__Sourc__55AEA362] DEFAULT (0) NULL,
    [SumHistPeriod]   SMALLINT            CONSTRAINT [DF_tblApHistHeader_SumHistPeriod] DEFAULT (0) NULL,
    [PmtCurrencyId]   [dbo].[pCurrency]   NULL,
    [PmtExchRate]     [dbo].[pDec]        DEFAULT ((1)) NOT NULL,
    [GLAcctAP]        [dbo].[pGlAcct]     NULL,
    [GLAcctFreight]   [dbo].[pGlAcct]     NULL,
    [GLAcctTaxAdj]    [dbo].[pGlAcct]     NULL,
    [GLAcctMisc]      [dbo].[pGlAcct]     NULL,
    [DiscDueDate]     DATETIME            NULL,
    [CF]              XML                 NULL,
    [BankID]          [dbo].[pBankID]     NULL,
    [ChkGlPeriod]     SMALLINT            NULL,
    [ChkFiscalYear]   SMALLINT            NULL,
    CONSTRAINT [PK__tblApHistHeader__00AA174D] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [InvoiceNum] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblApHistHeader] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblApHistHeader] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblApHistHeader] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblApHistHeader] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistHeader';

