CREATE TABLE [dbo].[tblSoPricePromo] (
    [PromoId]         VARCHAR (10)    NOT NULL,
    [Descr]           VARCHAR (35)    NULL,
    [PriceIdFrom]     VARCHAR (10)    NULL,
    [PriceIdThru]     VARCHAR (10)    NULL,
    [CustLevelFrom]   VARCHAR (10)    NULL,
    [CustLevelThru]   VARCHAR (10)    NULL,
    [ProductLineFrom] VARCHAR (12)    NULL,
    [ProductLineThru] VARCHAR (12)    NULL,
    [ItemIdFrom]      [dbo].[pItemID] NULL,
    [ItemIdThru]      [dbo].[pItemID] NULL,
    [UomFrom]         [dbo].[pUom]    NULL,
    [UomThru]         [dbo].[pUom]    NULL,
    [LocIdFrom]       [dbo].[pLocID]  NULL,
    [LocIdThru]       [dbo].[pLocID]  NULL,
    [UsrFld1From]     VARCHAR (12)    NULL,
    [UsrFld1Thru]     VARCHAR (12)    NULL,
    [UsrFld2From]     VARCHAR (12)    NULL,
    [UsrFld2Thru]     VARCHAR (12)    NULL,
    [PriceAdjBase]    TINYINT         CONSTRAINT [DF__tblSoPric__Price__78EDBDFE] DEFAULT (0) NOT NULL,
    [PriceAdjType]    TINYINT         CONSTRAINT [DF__tblSoPric__Price__79E1E237] DEFAULT (0) NOT NULL,
    [PriceAdjAmt]     [dbo].[pDec]    CONSTRAINT [DF_tblSoPricePromo_PriceAdjAmt] DEFAULT (0) NULL,
    [DateStart]       DATETIME        NULL,
    [DateEnd]         DATETIME        NULL,
    [WebOnlyYn]       BIT             CONSTRAINT [DF_tblSoPric_Price_Web] DEFAULT (0) NOT NULL,
    [ts]              ROWVERSION      NULL,
    [CF]              XML             NULL,
    CONSTRAINT [PK__tblSoPricePromo__77F999C5] PRIMARY KEY CLUSTERED ([PromoId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblSoPricePromo] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblSoPricePromo] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblSoPricePromo] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblSoPricePromo] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoPricePromo';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoPricePromo';

