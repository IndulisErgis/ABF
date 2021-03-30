CREATE TABLE [dbo].[tblSoSaleBlanket] (
    [BatchId]          [dbo].[pBatchID]   NOT NULL,
    [BlanketId]        [dbo].[pTransID]   NOT NULL,
    [BlanketType]      SMALLINT           DEFAULT ((0)) NOT NULL,
    [BlanketStatus]    SMALLINT           DEFAULT ((0)) NOT NULL,
    [ExpireDate]       DATETIME           NULL,
    [CloseDate]        DATETIME           NULL,
    [ContractDate]     DATETIME           DEFAULT (getdate()) NULL,
    [ContractAmount]   [dbo].[pDec]       DEFAULT ((0)) NOT NULL,
    [Freight]          [dbo].[pDec]       DEFAULT ((0)) NOT NULL,
    [Misc]             [dbo].[pDec]       DEFAULT ((0)) NOT NULL,
    [Subtotal]         [dbo].[pDec]       DEFAULT ((0)) NOT NULL,
    [LocId]            [dbo].[pLocID]     NULL,
    [SoldToId]         [dbo].[pCustID]    NULL,
    [CustId]           [dbo].[pCustID]    NULL,
    [CurrencyID]       [dbo].[pCurrency]  NULL,
    [CustLevel]        NVARCHAR (10)      NULL,
    [TermsCode]        [dbo].[pTermsCode] NULL,
    [DistCode]         [dbo].[pDistCode]  NULL,
    [TaxableYN]        BIT                DEFAULT ((1)) NOT NULL,
    [TaxOnFreight]     BIT                DEFAULT ((1)) NOT NULL,
    [TaxClassFreight]  TINYINT            DEFAULT ((0)) NOT NULL,
    [TaxClassMisc]     TINYINT            DEFAULT ((0)) NOT NULL,
    [TaxGrpID]         [dbo].[pTaxLoc]    NULL,
    [PODate]           DATETIME           DEFAULT (getdate()) NULL,
    [CustPONum]        NVARCHAR (25)      NULL,
    [ShipToID]         [dbo].[pCustID]    NULL,
    [ShipToName]       NVARCHAR (30)      NULL,
    [ShipToAddr1]      NVARCHAR (30)      NULL,
    [ShipToAddr2]      NVARCHAR (60)      NULL,
    [ShipToCity]       NVARCHAR (30)      NULL,
    [ShipToRegion]     NVARCHAR (10)      NULL,
    [ShipToCountry]    [dbo].[pCountry]   NULL,
    [ShipToPostalCode] NVARCHAR (10)      NULL,
    [ShipToPhone]      NVARCHAR (24)      NULL,
    [ShipVia]          NVARCHAR (20)      NULL,
    [Rep1Id]           [dbo].[pSalesRep]  NULL,
    [Rep1Pct]          [dbo].[pDec]       DEFAULT ((0)) NOT NULL,
    [Rep1CommRate]     [dbo].[pDec]       DEFAULT ((0)) NOT NULL,
    [Rep2Id]           [dbo].[pSalesRep]  NULL,
    [Rep2Pct]          [dbo].[pDec]       DEFAULT ((0)) NOT NULL,
    [Rep2CommRate]     [dbo].[pDec]       DEFAULT ((0)) NOT NULL,
    [Notes]            NVARCHAR (MAX)     NULL,
    [ts]               ROWVERSION         NULL,
    [CF]               XML                NULL,
    [BlanketRef]       INT                NOT NULL,
    [ShipToAttn]       NVARCHAR (30)      NULL,
    [ShipMethod]       NVARCHAR (6)       NULL,
    CONSTRAINT [PK_tblSoSaleBlanket] PRIMARY KEY CLUSTERED ([BlanketRef] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoSaleBlanket';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoSaleBlanket';

