CREATE TABLE [dbo].[ALP_tblJmKitItemSm] (
    [KitItemsId] INT          IDENTITY (1, 1) NOT NULL,
    [KitItemId]  VARCHAR (24) NOT NULL,
    [Qty]        FLOAT (53)   NOT NULL,
    [ItemId]     VARCHAR (24) NOT NULL,
    [Uom]        VARCHAR (5)  NOT NULL,
    [EquipLoc]   VARCHAR (30) NULL,
    [Zone]       VARCHAR (5)  NULL,
    [ts]         ROWVERSION   NULL,
    CONSTRAINT [PK_tblJmKitItemSm] PRIMARY KEY CLUSTERED ([KitItemsId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmKitItemSm] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmKitItemSm] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmKitItemSm] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmKitItemSm] TO PUBLIC
    AS [dbo];

