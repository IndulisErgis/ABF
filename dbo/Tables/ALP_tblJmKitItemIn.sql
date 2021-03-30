CREATE TABLE [dbo].[ALP_tblJmKitItemIn] (
    [KitsItemId] INT             IDENTITY (1, 1) NOT NULL,
    [KitItemId]  [dbo].[pItemID] NOT NULL,
    [KitLocId]   [dbo].[pLocID]  NOT NULL,
    [Qty]        FLOAT (53)      NOT NULL,
    [ItemId]     [dbo].[pItemID] NOT NULL,
    [Uom]        VARCHAR (5)     NOT NULL,
    [EquipLoc]   VARCHAR (30)    NULL,
    [Zone]       VARCHAR (5)     NULL,
    [ts]         ROWVERSION      NULL,
    CONSTRAINT [PK_tblJmKitItemIn] PRIMARY KEY CLUSTERED ([KitsItemId] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmKitItemIn] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmKitItemIn] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmKitItemIn] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmKitItemIn] TO PUBLIC
    AS [dbo];

