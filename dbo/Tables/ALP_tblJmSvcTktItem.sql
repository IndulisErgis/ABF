CREATE TABLE [dbo].[ALP_tblJmSvcTktItem] (
    [TicketItemId]              INT             IDENTITY (1, 1) NOT NULL,
    [TicketId]                  INT             NULL,
    [ResolutionId]              INT             NULL,
    [ResDesc]                   TEXT            NULL,
    [CauseId]                   INT             NULL,
    [CauseDesc]                 TEXT            NULL,
    [SelectFromInvYn]           BIT             CONSTRAINT [DF_tblJmSvcTktItem_SelectFromInvYn] DEFAULT (0) NULL,
    [ItemNotInListYn]           BIT             CONSTRAINT [DF_tblJmSvcTktItem_ItemNotInListYn] DEFAULT (0) NULL,
    [ItemId]                    [dbo].[pItemID] NULL,
    [KitRef]                    INT             NULL,
    [Desc]                      VARCHAR (255)   NULL,
    [TreatAsPartYN]             BIT             CONSTRAINT [DF_tblJmSvcTktItem_TreatAsPartYN] DEFAULT (1) NULL,
    [PrintOnInvoice]            BIT             CONSTRAINT [DF_tblJmSvcTktItem_PrintOnInvoice] DEFAULT (0) NULL,
    [WhseID]                    VARCHAR (10)    NULL,
    [QtyAdded]                  [dbo].[pDec]    CONSTRAINT [DF_tblJmSvcTktItem_QtyAdded] DEFAULT (0) NULL,
    [QtyRemoved]                [dbo].[pDec]    CONSTRAINT [DF_tblJmSvcTktItem_QtyRemoved] DEFAULT (0) NULL,
    [QtyServiced]               [dbo].[pDec]    CONSTRAINT [DF_tblJmSvcTktItem_QtyServiced] DEFAULT (0) NULL,
    [SerNum]                    VARCHAR (35)    NULL,
    [EquipLoc]                  VARCHAR (30)    NULL,
    [WarrExpDate]               DATETIME        NULL,
    [CopyToYN]                  BIT             CONSTRAINT [DF_tblJmSvcTktItem_CopyToYN] DEFAULT (0) NULL,
    [UnitPrice]                 [dbo].[pDec]    CONSTRAINT [DF_tblJmSvcTktItem_UnitPrice] DEFAULT (0) NULL,
    [UnitCost]                  [dbo].[pDec]    CONSTRAINT [DF_tblJmSvcTktItem_UnitCost] DEFAULT (0) NULL,
    [UnitPts]                   FLOAT (53)      CONSTRAINT [DF_tblJmSvcTktItem_UnitPts] DEFAULT (0) NULL,
    [Comments]                  TEXT            NULL,
    [Zone]                      VARCHAR (5)     NULL,
    [ItemType]                  VARCHAR (50)    NULL,
    [KittedYN]                  BIT             CONSTRAINT [DF_tblJmSvcTktItem_KittedYN] DEFAULT (0) NULL,
    [SysItemId]                 INT             NULL,
    [PanelYN]                   BIT             CONSTRAINT [DF_tblJmSvcTktItem_PanelYN] DEFAULT (0) NULL,
    [Uom]                       VARCHAR (5)     NULL,
    [PartPulledDate]            DATETIME        NULL,
    [CosOffset]                 VARCHAR (40)    NULL,
    [UnitHrs]                   [dbo].[pDec]    CONSTRAINT [DF_tblJmSvcTktItem_UnitHrs] DEFAULT (0) NULL,
    [AlpVendorKitYn]            BIT             CONSTRAINT [DF_tblJmSvcTktItem_AlpVendorKitYn] DEFAULT (0) NULL,
    [AlpVendorKitComponentYn]   BIT             CONSTRAINT [DF_tblJmSvcTktItem_AlpVendorKitComponentYn] DEFAULT (0) NULL,
    [ts]                        ROWVERSION      NULL,
    [QtySeqNum_Cmtd]            INT             CONSTRAINT [DF_tblJmSvcTktItem_QtySeqNum_Cmtd] DEFAULT (0) NULL,
    [QtySeqNum_InUse]           INT             CONSTRAINT [DF_tblJmSvcTktItem_QtySeqNum_InUse] DEFAULT (0) NULL,
    [LineNumber]                VARCHAR (50)    CONSTRAINT [DF_tblJmSvcTktItem_LineNumber] DEFAULT ('') NULL,
    [KitNestLevel]              SMALLINT        CONSTRAINT [DF_tblJmSvcTktItem_KitNestLevel] DEFAULT (0) NULL,
    [ModifiedBy]                VARCHAR (50)    NULL,
    [ModifiedDate]              DATETIME        NULL,
    [NonContractItem]           BIT             CONSTRAINT [DF_tblJmSvcTktItem_NonContractItem] DEFAULT ((0)) NULL,
    [PhaseId]                   INT             NULL,
    [BinNumber]                 VARCHAR (10)    NULL,
    [StagedDate]                DATETIME        NULL,
    [BODate]                    DATETIME        NULL,
    [OldTicketId]               INT             NULL,
    [UnitPriceIsFinalSalePrice] BIT             CONSTRAINT [DF_ALP_tblJmSvcTktItem_UnitPriceIsFinalSalePrice] DEFAULT ((0)) NULL,
    [SalePrice]                 [dbo].[pDec]    NULL,
    [ExtSalePrice]              [dbo].[pDec]    NULL,
    [ExtSalePriceFlg]           INT             DEFAULT ((0)) NOT NULL,
    [HoldInvCommitted]          BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblJmSvcTktItem] PRIMARY KEY CLUSTERED ([TicketItemId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblJmSvcTktItem]
    ON [dbo].[ALP_tblJmSvcTktItem]([TicketId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmSvcTktItem] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmSvcTktItem] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmSvcTktItem] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmSvcTktItem] TO PUBLIC
    AS [dbo];

