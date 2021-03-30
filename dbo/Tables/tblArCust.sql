CREATE TABLE [dbo].[tblArCust] (
    [CustId]             [dbo].[pCustID]     NOT NULL,
    [CustName]           VARCHAR (30)        NULL,
    [Contact]            VARCHAR (25)        NULL,
    [Addr1]              VARCHAR (30)        NULL,
    [Addr2]              VARCHAR (60)        NULL,
    [City]               VARCHAR (30)        NULL,
    [Region]             VARCHAR (10)        NULL,
    [Country]            [dbo].[pCountry]    NULL,
    [PostalCode]         VARCHAR (10)        NULL,
    [ShipZone]           VARCHAR (2)         NULL,
    [IntlPrefix]         VARCHAR (6)         NULL,
    [Phone]              VARCHAR (15)        NULL,
    [Fax]                VARCHAR (15)        NULL,
    [Attn]               VARCHAR (30)        NULL,
    [ClassId]            VARCHAR (6)         NULL,
    [SalesRepId1]        [dbo].[pSalesRep]   NULL,
    [SalesRepId2]        [dbo].[pSalesRep]   NULL,
    [Rep1PctInvc]        [dbo].[pDec]        CONSTRAINT [DF_tblArCust_Rep1PctInvc] DEFAULT (0) NULL,
    [Rep2PctInvc]        [dbo].[pDec]        CONSTRAINT [DF_tblArCust_Rep2PctInvc] DEFAULT (0) NULL,
    [TermsCode]          [dbo].[pTermsCode]  NOT NULL,
    [PmtMethod]          VARCHAR (10)        NOT NULL,
    [GroupCode]          VARCHAR (1)         NULL,
    [StmtInvcCode]       TINYINT             CONSTRAINT [DF__tblArCust__StmtI__60813790] DEFAULT (3) NULL,
    [AcctType]           TINYINT             CONSTRAINT [DF__tblArCust__AcctT__61755BC9] DEFAULT (0) NULL,
    [PriceCode]          VARCHAR (10)        NULL,
    [DistCode]           [dbo].[pDistCode]   NOT NULL,
    [CalcFinch]          BIT                 CONSTRAINT [DF__tblArCust__CalcF__62698002] DEFAULT (1) NULL,
    [CreditLimit]        [dbo].[pDec]        CONSTRAINT [DF_tblArCust_CreditLimit] DEFAULT (0) NULL,
    [CreditHold]         BIT                 CONSTRAINT [DF__tblArCust__Credi__6451C874] DEFAULT (0) NULL,
    [PartialShip]        BIT                 CONSTRAINT [DF__tblArCust__Parti__6545ECAD] DEFAULT (1) NULL,
    [AutoCreditHold]     BIT                 CONSTRAINT [DF__tblArCust__AutoC__663A10E6] DEFAULT (1) NULL,
    [TaxLocId]           [dbo].[pTaxLoc]     NOT NULL,
    [Taxable]            BIT                 CONSTRAINT [DF__tblArCust__Taxab__672E351F] DEFAULT (1) NULL,
    [TaxExemptId]        VARCHAR (20)        NULL,
    [CurrencyId]         [dbo].[pCurrency]   NOT NULL,
    [TerrId]             VARCHAR (10)        NULL,
    [CcCompYn]           BIT                 CONSTRAINT [DF__tblArCust__CcCom__68225958] DEFAULT (0) NULL,
    [CustLevel]          VARCHAR (10)        NULL,
    [Email]              [dbo].[pEmail]      NULL,
    [Internet]           [dbo].[pWeb]        NULL,
    [NewFinch]           [dbo].[pDec]        CONSTRAINT [DF_tblArCust_NewFinch] DEFAULT (0) NOT NULL,
    [UnpaidFinch]        [dbo].[pDec]        CONSTRAINT [DF_tblArCust_UnpaidFinch] DEFAULT (0) NOT NULL,
    [CurAmtDue]          [dbo].[pDec]        CONSTRAINT [DF_tblArCust_CurAmtDue] DEFAULT (0) NOT NULL,
    [CurAmtDueFgn]       [dbo].[pDec]        CONSTRAINT [DF_tblArCust_CurAmtDueFgn] DEFAULT (0) NOT NULL,
    [BalAge1]            [dbo].[pDec]        CONSTRAINT [DF_tblArCust_BalAge1] DEFAULT (0) NOT NULL,
    [BalAge2]            [dbo].[pDec]        CONSTRAINT [DF_tblArCust_BalAge2] DEFAULT (0) NOT NULL,
    [BalAge3]            [dbo].[pDec]        CONSTRAINT [DF_tblArCust_BalAge3] DEFAULT (0) NOT NULL,
    [BalAge4]            [dbo].[pDec]        CONSTRAINT [DF_tblArCust_BalAge4] DEFAULT (0) NOT NULL,
    [UnapplCredit]       [dbo].[pDec]        CONSTRAINT [DF_tblArCust_UnapplCredit] DEFAULT (0) NOT NULL,
    [FirstSaleDate]      DATETIME            NULL,
    [LastSaleDate]       DATETIME            NULL,
    [LastSaleAmt]        [dbo].[pDec]        CONSTRAINT [DF_tblArCust_LastSaleAmt] DEFAULT (0) NOT NULL,
    [LastSaleInvc]       [dbo].[pInvoiceNum] NULL,
    [LastPayDate]        DATETIME            NULL,
    [LastPayAmt]         [dbo].[pDec]        CONSTRAINT [DF_tblArCust_LastPayAmt] DEFAULT (0) NOT NULL,
    [LastPayCheckNum]    [dbo].[pCheckNum]   NULL,
    [HighBal]            [dbo].[pDec]        CONSTRAINT [DF_tblArCust_HighBal] DEFAULT (0) NOT NULL,
    [CreditStatus]       VARCHAR (12)        NULL,
    [WebDisplInQtyYn]    BIT                 CONSTRAINT [DF_tblArCust_Web] DEFAULT (0) NOT NULL,
    [ts]                 ROWVERSION          NULL,
    [AllowCharge]        BIT                 CONSTRAINT [DF__tblArCust__Allow__616445E3] DEFAULT ((0)) NOT NULL,
    [Phone1]             VARCHAR (15)        NULL,
    [Phone2]             VARCHAR (15)        NULL,
    [BillToId]           [dbo].[pCustID]     NULL,
    [Status]             TINYINT             DEFAULT ((0)) NOT NULL,
    [CF]                 XML                 NULL,
    [PONumberRequiredYn] BIT                 CONSTRAINT [DF_tblArCust_PONumberRequiredYn] DEFAULT ((0)) NOT NULL,
    [TaxCertExpDate]     DATETIME            NULL,
    CONSTRAINT [PK__tblArCust__5DA4CAE5] PRIMARY KEY CLUSTERED ([CustId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlAcctType]
    ON [dbo].[tblArCust]([AcctType] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblArCust] TO [WebUserRole]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArCust] TO [WebUserRole]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblArCust] TO [WebUserRole]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblArCust] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArCust';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArCust';

