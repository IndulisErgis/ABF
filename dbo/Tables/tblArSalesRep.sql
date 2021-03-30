CREATE TABLE [dbo].[tblArSalesRep] (
    [SalesRepID]     [dbo].[pSalesRep] NOT NULL,
    [Name]           VARCHAR (30)      NULL,
    [Addr1]          VARCHAR (30)      NULL,
    [Addr2]          VARCHAR (60)      NULL,
    [City]           VARCHAR (30)      NULL,
    [Region]         VARCHAR (10)      NULL,
    [Country]        [dbo].[pCountry]  NULL,
    [PostalCode]     VARCHAR (10)      NULL,
    [IntlPrefix]     VARCHAR (6)       NULL,
    [Phone]          VARCHAR (15)      NULL,
    [Fax]            VARCHAR (15)      NULL,
    [EmplId]         [dbo].[pEmpID]    NULL,
    [RunCode]        VARCHAR (10)      NULL,
    [CommRate]       [dbo].[pDec]      CONSTRAINT [DF_tblArSalesRep_CommRate] DEFAULT (0) NULL,
    [PctOf]          TINYINT           CONSTRAINT [DF__tblArSale__PctOf__7329F7B0] DEFAULT (0) NULL,
    [BasedOn]        TINYINT           CONSTRAINT [DF__tblArSale__Based__741E1BE9] DEFAULT (0) NULL,
    [PayOnLineItems] BIT               CONSTRAINT [DF__tblArSale__PayOn__75124022] DEFAULT (1) NULL,
    [PayOnSalesTax]  BIT               CONSTRAINT [DF__tblArSale__PayOn__7606645B] DEFAULT (0) NULL,
    [PayOnFreight]   BIT               CONSTRAINT [DF__tblArSale__PayOn__76FA8894] DEFAULT (0) NULL,
    [PayOnMisc]      BIT               CONSTRAINT [DF__tblArSale__PayOn__77EEACCD] DEFAULT (0) NULL,
    [PTDSales]       [dbo].[pDec]      CONSTRAINT [DF_tblArSalesRep_PTDSales] DEFAULT (0) NULL,
    [YTDSales]       [dbo].[pDec]      CONSTRAINT [DF_tblArSalesRep_YTDSales] DEFAULT (0) NULL,
    [LastSalesDate]  DATETIME          NULL,
    [Email]          [dbo].[pEmail]    NULL,
    [Internet]       [dbo].[pWeb]      NULL,
    [ts]             ROWVERSION        NULL,
    [EarnCode]       [dbo].[pCode]     NULL,
    [PayVia]         TINYINT           DEFAULT ((0)) NOT NULL,
    [VendorId]       [dbo].[pVendorID] NULL,
    [CF]             XML               NULL,
    CONSTRAINT [PK__tblArSalesRep__7141AF3E] PRIMARY KEY CLUSTERED ([SalesRepID] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArSalesRep] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArSalesRep';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArSalesRep';

