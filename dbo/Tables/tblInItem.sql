CREATE TABLE [dbo].[tblInItem] (
    [ItemId]             [dbo].[pItemID] NOT NULL,
    [Descr]              VARCHAR (35)    NULL,
    [SuperId]            [dbo].[pItemID] NULL,
    [ItemType]           TINYINT         CONSTRAINT [DF__tblInItem__ItemT__476B7103] DEFAULT (1) NULL,
    [ItemStatus]         TINYINT         CONSTRAINT [DF__tblInItem__ItemS__485F953C] DEFAULT (1) NULL,
    [ProductLine]        VARCHAR (12)    NULL,
    [SalesCat]           VARCHAR (2)     NULL,
    [PriceId]            VARCHAR (10)    NULL,
    [TaxClass]           TINYINT         CONSTRAINT [DF__tblInItem__TaxCl__4953B975] DEFAULT (0) NULL,
    [UomBase]            [dbo].[pUom]    NULL,
    [UomDflt]            [dbo].[pUom]    NULL,
    [LottedYN]           BIT             CONSTRAINT [DF__tblInItem__Lotte__4A47DDAE] DEFAULT (0) NULL,
    [AutoReorderYN]      BIT             CONSTRAINT [DF__tblInItem__AutoR__4B3C01E7] DEFAULT (0) NULL,
    [KittedYN]           SMALLINT        CONSTRAINT [DF__tblInItem__Kitte__4C302620] DEFAULT (0) NULL,
    [ResaleYN]           BIT             CONSTRAINT [DF__tblInItem__Resal__4D244A59] DEFAULT (1) NULL,
    [PictId]             VARCHAR (10)    NULL,
    [UsrFld1]            VARCHAR (12)    NULL,
    [UsrFld2]            VARCHAR (12)    NULL,
    [UsrFld3]            VARCHAR (12)    NULL,
    [UsrFld4]            VARCHAR (12)    NULL,
    [ts]                 ROWVERSION      NULL,
    [CostMethodOverride] TINYINT         DEFAULT ((0)) NULL,
    [HMRef]              INT             NULL,
    [CF]                 XML             NULL,
    [CommodityCode]      NVARCHAR (25)   NULL,
    CONSTRAINT [PK__tblInItem__46774CCA] PRIMARY KEY CLUSTERED ([ItemId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblInItem] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItem';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInItem';

