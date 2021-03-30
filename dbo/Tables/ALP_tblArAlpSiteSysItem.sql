CREATE TABLE [dbo].[ALP_tblArAlpSiteSysItem] (
    [SysItemId]    INT              IDENTITY (1, 1) NOT NULL,
    [SysId]        INT              NULL,
    [ItemId]       VARCHAR (24)     NULL,
    [Desc]         VARCHAR (255)    NULL,
    [LocId]        VARCHAR (10)     NULL,
    [PanelYN]      BIT              CONSTRAINT [DF_ALP_tblArAlpSiteSysItem_PanelYN] DEFAULT ((0)) NOT NULL,
    [SerNum]       VARCHAR (35)     NULL,
    [EquipLoc]     VARCHAR (30)     NULL,
    [Qty]          FLOAT (53)       NULL,
    [UnitCost]     NUMERIC (20, 10) NULL,
    [WarrPlanId]   INT              NULL,
    [WarrTerm]     SMALLINT         NULL,
    [WarrStarts]   DATETIME         NULL,
    [WarrExpires]  DATETIME         NULL,
    [Comments]     TEXT             NULL,
    [RemoveYN]     BIT              CONSTRAINT [DF_ALP_tblArAlpSiteSysItem_RemoveYN] DEFAULT ((0)) NOT NULL,
    [Zone]         VARCHAR (5)      NULL,
    [TicketId]     INT              NULL,
    [WorkOrderId]  INT              NULL,
    [RepPlanId]    INT              NULL,
    [LeaseYN]      BIT              CONSTRAINT [DF_ALP_tblArAlpSiteSysItem_LeaseYN] DEFAULT ((0)) NOT NULL,
    [ts]           ROWVERSION       NULL,
    [ModifiedBy]   VARCHAR (50)     NULL,
    [ModifiedDate] DATETIME         NULL,
    CONSTRAINT [PK_tblArAlpSiteSysItem] PRIMARY KEY CLUSTERED ([SysItemId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_ALP_tblArAlpSiteSysItem_SysId]
    ON [dbo].[ALP_tblArAlpSiteSysItem]([SysId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblArAlpSiteSysItem]
    ON [dbo].[ALP_tblArAlpSiteSysItem]([SysId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteSysItem] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteSysItem] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblArAlpSiteSysItem] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblArAlpSiteSysItem] TO PUBLIC
    AS [dbo];

