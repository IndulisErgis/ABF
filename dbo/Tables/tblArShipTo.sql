CREATE TABLE [dbo].[tblArShipTo] (
    [CustId]      [dbo].[pCustID]   NOT NULL,
    [ShiptoId]    [dbo].[pCustID]   NOT NULL,
    [ShiptoName]  VARCHAR (30)      NULL,
    [Addr1]       VARCHAR (30)      NULL,
    [Addr2]       VARCHAR (60)      NULL,
    [City]        VARCHAR (30)      NULL,
    [Region]      VARCHAR (10)      NULL,
    [Country]     [dbo].[pCountry]  NULL,
    [PostalCode]  VARCHAR (10)      NULL,
    [IntlPrefix]  VARCHAR (6)       NULL,
    [Phone]       VARCHAR (15)      NULL,
    [Fax]         VARCHAR (15)      NULL,
    [Attn]        VARCHAR (30)      NULL,
    [ShipVia]     VARCHAR (20)      NULL,
    [TaxLocID]    [dbo].[pTaxLoc]   NULL,
    [TerrId]      VARCHAR (10)      NULL,
    [DistCode]    [dbo].[pDistCode] NULL,
    [Email]       [dbo].[pEmail]    NULL,
    [Internet]    [dbo].[pWeb]      NULL,
    [AddressType] TINYINT           CONSTRAINT [DF__tblArShip__Addre__7E9BAA5C] DEFAULT (0) NULL,
    [ts]          ROWVERSION        NULL,
    [Phone1]      VARCHAR (15)      NULL,
    [Phone2]      VARCHAR (15)      NULL,
    [CF]          XML               NULL,
    [Rep1Id]      [dbo].[pSalesRep] NULL,
    [Rep2Id]      [dbo].[pSalesRep] NULL,
    [Rep1PctInvc] [dbo].[pDecimal]  CONSTRAINT [DF_tblArShipTo_Rep1PctInvc] DEFAULT ((0)) NOT NULL,
    [Rep2PctInvc] [dbo].[pDecimal]  CONSTRAINT [DF_tblArShipTo_Rep2PctInvc] DEFAULT ((0)) NOT NULL,
    [ShipMethod]  NVARCHAR (6)      NULL,
    CONSTRAINT [PK__tblArShipTo__3BCADD1B] PRIMARY KEY CLUSTERED ([CustId] ASC, [ShiptoId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArShipTo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArShipTo';

