CREATE TABLE [dbo].[tblPoTransInvoiceTax] (
    [TransId]           [dbo].[pTransID]    NOT NULL,
    [InvcNum]           [dbo].[pInvoiceNum] NOT NULL,
    [TaxLocID]          [dbo].[pTaxLoc]     NOT NULL,
    [TaxClass]          TINYINT             CONSTRAINT [DF__tblPoTran__TaxCl__478B6C94] DEFAULT (0) NOT NULL,
    [ExpAcct]           [dbo].[pGlAcct]     NOT NULL,
    [CurrTaxAmt]        [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrT__487F90CD] DEFAULT (0) NULL,
    [CurrRefundable]    [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrR__4973B506] DEFAULT (0) NULL,
    [CurrTaxable]       [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrT__4A67D93F] DEFAULT (0) NULL,
    [CurrNonTaxable]    [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrN__4B5BFD78] DEFAULT (0) NULL,
    [RefundAcct]        [dbo].[pGlAcct]     NULL,
    [CurrTaxAmtFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrT__4C5021B1] DEFAULT (0) NULL,
    [CurrRefundableFgn] [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrR__4D4445EA] DEFAULT (0) NULL,
    [CurrTaxableFgn]    [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrT__4E386A23] DEFAULT (0) NULL,
    [CurrNonTaxableFgn] [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrN__4F2C8E5C] DEFAULT (0) NULL,
    [ts]                ROWVERSION          NULL,
    [CF]                XML                 NULL,
    CONSTRAINT [PK__tblPoTransInvoic__08D548FA] PRIMARY KEY CLUSTERED ([TransId] ASC, [InvcNum] ASC, [TaxLocID] ASC, [TaxClass] ASC, [ExpAcct] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransInvoiceTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransInvoiceTax';

