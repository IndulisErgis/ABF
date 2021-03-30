﻿CREATE TABLE [dbo].[tblPoTransInvoiceTot] (
    [TransId]             [dbo].[pTransID]    NOT NULL,
    [InvcNum]             [dbo].[pInvoiceNum] NOT NULL,
    [Status]              TINYINT             CONSTRAINT [DF__tblPoTran__Statu__5208FB07] DEFAULT (0) NULL,
    [InvcDate]            DATETIME            CONSTRAINT [DF__tblPoTran__InvcD__52FD1F40] DEFAULT (getdate()) NULL,
    [GLPeriod]            SMALLINT            CONSTRAINT [DF__tblPoTran__GLPer__53F14379] DEFAULT (0) NULL,
    [FiscalYear]          SMALLINT            CONSTRAINT [DF__tblPoTran__Fisca__54E567B2] DEFAULT (0) NULL,
    [Ten99InvoiceYN]      BIT                 CONSTRAINT [DF__tblPoTran__Ten99__55D98BEB] DEFAULT (0) NULL,
    [CurrTaxable]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrT__56CDB024] DEFAULT (0) NULL,
    [CurrNonTaxable]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrN__57C1D45D] DEFAULT (0) NULL,
    [CurrSalesTax]        [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrS__58B5F896] DEFAULT (0) NULL,
    [CurrFreight]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrF__59AA1CCF] DEFAULT (0) NULL,
    [CurrMisc]            [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrM__5A9E4108] DEFAULT (0) NULL,
    [CurrDisc]            [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrD__5B926541] DEFAULT (0) NULL,
    [CurrPrepaid]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrP__5C86897A] DEFAULT (0) NULL,
    [CurrTaxableFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrT__5D7AADB3] DEFAULT (0) NULL,
    [CurrNonTaxableFgn]   [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrN__5E6ED1EC] DEFAULT (0) NULL,
    [CurrSalesTaxFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrS__5F62F625] DEFAULT (0) NULL,
    [CurrFreightFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrF__60571A5E] DEFAULT (0) NULL,
    [CurrMiscFgn]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrM__614B3E97] DEFAULT (0) NULL,
    [CurrDiscFgn]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrD__623F62D0] DEFAULT (0) NULL,
    [CurrPrepaidFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrP__63338709] DEFAULT (0) NULL,
    [PostTaxable]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostT__6427AB42] DEFAULT (0) NULL,
    [PostNonTaxable]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostN__651BCF7B] DEFAULT (0) NULL,
    [PostSalesTax]        [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostS__660FF3B4] DEFAULT (0) NULL,
    [PostFreight]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostF__670417ED] DEFAULT (0) NULL,
    [PostMisc]            [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostM__67F83C26] DEFAULT (0) NULL,
    [PostDisc]            [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostD__68EC605F] DEFAULT (0) NULL,
    [PostPrepaid]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostP__69E08498] DEFAULT (0) NULL,
    [PostTaxableFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostT__6AD4A8D1] DEFAULT (0) NULL,
    [PostNonTaxableFgn]   [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostN__6BC8CD0A] DEFAULT (0) NULL,
    [PostSalesTaxFgn]     [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostS__6CBCF143] DEFAULT (0) NULL,
    [PostFreightFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostF__6DB1157C] DEFAULT (0) NULL,
    [PostMiscFgn]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostM__6EA539B5] DEFAULT (0) NULL,
    [PostDiscFgn]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostD__6F995DEE] DEFAULT (0) NULL,
    [PostPrepaidFgn]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__PostP__708D8227] DEFAULT (0) NULL,
    [CurrCheckNo]         [dbo].[pCheckNum]   NULL,
    [CurrCheckDate]       DATETIME            NULL,
    [CurrDueDate1]        DATETIME            NULL,
    [CurrDueDate2]        DATETIME            NULL,
    [CurrDueDate3]        DATETIME            NULL,
    [CurrPmtAmt1]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrP__7181A660] DEFAULT (0) NULL,
    [CurrPmtAmt2]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrP__7275CA99] DEFAULT (0) NULL,
    [CurrPmtAmt3]         [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrP__7369EED2] DEFAULT (0) NULL,
    [CurrPmtAmt1Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrP__745E130B] DEFAULT (0) NULL,
    [CurrPmtAmt2Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrP__75523744] DEFAULT (0) NULL,
    [CurrPmtAmt3Fgn]      [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrP__76465B7D] DEFAULT (0) NULL,
    [CurrTaxClassFreight] TINYINT             CONSTRAINT [DF__tblPoTran__CurrT__773A7FB6] DEFAULT (0) NULL,
    [CurrTaxClassMisc]    TINYINT             CONSTRAINT [DF__tblPoTran__CurrT__782EA3EF] DEFAULT (0) NULL,
    [CurrTaxAdjClass]     TINYINT             CONSTRAINT [DF__tblPoTran__CurrT__7922C828] DEFAULT (0) NULL,
    [CurrTaxAdjLocID]     [dbo].[pTaxLoc]     NULL,
    [CurrTaxAdjAmt]       [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrT__7A16EC61] DEFAULT (0) NULL,
    [CurrTaxAdjAmtFgn]    [dbo].[pDec]        CONSTRAINT [DF__tblPoTran__CurrT__7B0B109A] DEFAULT (0) NULL,
    [ts]                  ROWVERSION          NULL,
    [CurrBankID]          [dbo].[pBankID]     NULL,
    [CurrChkGlPeriod]     SMALLINT            NULL,
    [CurrChkFiscalYear]   SMALLINT            NULL,
    [InvoiceExchRate]     [dbo].[pDec]        DEFAULT ((1)) NOT NULL,
    [PmtCurrencyId]       [dbo].[pCurrency]   NULL,
    [PmtExchRate]         [dbo].[pDec]        DEFAULT ((1)) NOT NULL,
    [GainLoss]            [dbo].[pDec]        DEFAULT ((0)) NULL,
    [DiscDueDate]         DATETIME            NULL,
    [CF]                  XML                 NULL,
    CONSTRAINT [PK__tblPoTransInvoic__09C96D33] PRIMARY KEY CLUSTERED ([TransId] ASC, [InvcNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransInvoiceTot';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransInvoiceTot';
