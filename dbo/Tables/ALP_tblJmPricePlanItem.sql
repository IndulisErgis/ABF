CREATE TABLE [dbo].[ALP_tblJmPricePlanItem] (
    [ItemPricePlanId] INT           IDENTITY (1, 1) NOT NULL,
    [ItemId]          VARCHAR (24)  NOT NULL,
    [LocId]           VARCHAR (10)  NOT NULL,
    [PriceId]         VARCHAR (15)  NULL,
    [CustLevel]       VARCHAR (10)  NULL,
    [Desc]            VARCHAR (255) NULL,
    [PriceAdjBase]    INT           NULL,
    [PriceAdjType]    INT           NULL,
    [PriceAdjAmt]     [dbo].[pDec]  NULL,
    [ts]              ROWVERSION    NULL,
    CONSTRAINT [PK_tblJmPricePlanItem] PRIMARY KEY CLUSTERED ([ItemPricePlanId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_tblJmPricePlanItem_tblJmPricePlanGenHeader] FOREIGN KEY ([PriceId]) REFERENCES [dbo].[ALP_tblJmPricePlanGenHeader] ([PriceId])
);


GO
CREATE NONCLUSTERED INDEX [IX_tblJmPricePlanItem_ItemLoc]
    ON [dbo].[ALP_tblJmPricePlanItem]([ItemId] ASC, [LocId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_tblJmPricePlanItem_PriceId]
    ON [dbo].[ALP_tblJmPricePlanItem]([PriceId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmPricePlanItem] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmPricePlanItem] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmPricePlanItem] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmPricePlanItem] TO PUBLIC
    AS [dbo];

