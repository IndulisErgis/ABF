CREATE TABLE [dbo].[tblInLoc] (
    [LocId]        [dbo].[pLocID]   NOT NULL,
    [Descr]        VARCHAR (35)     NULL,
    [Addr1]        VARCHAR (30)     NULL,
    [Addr2]        VARCHAR (60)     NULL,
    [City]         VARCHAR (30)     NULL,
    [Region]       VARCHAR (10)     NULL,
    [PostalCode]   VARCHAR (10)     NULL,
    [Country]      [dbo].[pCountry] NOT NULL,
    [Contact]      VARCHAR (25)     NULL,
    [zzIntlPreFix] VARCHAR (6)      NULL,
    [Phone]        VARCHAR (15)     NULL,
    [Fax]          VARCHAR (15)     NULL,
    [CarrCostPct]  [dbo].[pDec]     CONSTRAINT [DF__tblInLoc__CarrCo__323B49F3] DEFAULT (0) NULL,
    [OrderCostAmt] [dbo].[pDec]     CONSTRAINT [DF__tblInLoc__OrderC__332F6E2C] DEFAULT (0) NULL,
    [Email]        [dbo].[pEmail]   NULL,
    [Internet]     [dbo].[pWeb]     NULL,
    [ts]           ROWVERSION       NULL,
    [CF]           XML              NULL,
    CONSTRAINT [PK__tblInLoc__25A691D2] PRIMARY KEY CLUSTERED ([LocId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInLoc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInLoc';

