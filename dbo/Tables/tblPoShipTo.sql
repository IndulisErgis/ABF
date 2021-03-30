CREATE TABLE [dbo].[tblPoShipTo] (
    [ShiptoId]   [dbo].[pCustID]   NOT NULL,
    [ShiptoName] VARCHAR (30)      NULL,
    [Addr1]      VARCHAR (30)      NULL,
    [Addr2]      VARCHAR (60)      NULL,
    [City]       VARCHAR (30)      NULL,
    [Region]     VARCHAR (10)      NULL,
    [Country]    [dbo].[pCountry]  NOT NULL,
    [PostalCode] VARCHAR (10)      NULL,
    [IntlPrefix] VARCHAR (6)       NULL,
    [Phone]      VARCHAR (15)      NULL,
    [Fax]        VARCHAR (15)      NULL,
    [Attn]       VARCHAR (30)      NULL,
    [ShipVia]    VARCHAR (20)      NULL,
    [TaxLocID]   [dbo].[pTaxLoc]   NULL,
    [DistCode]   [dbo].[pDistCode] NULL,
    [Email]      [dbo].[pEmail]    NULL,
    [Internet]   [dbo].[pWeb]      NULL,
    [ts]         ROWVERSION        NULL,
    [CF]         XML               NULL,
    CONSTRAINT [PK__tblPoShipTo__041093DD] PRIMARY KEY CLUSTERED ([ShiptoId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoShipTo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoShipTo';

