CREATE TABLE [dbo].[tblPoPurchaseReq] (
    [ReqId]          INT                  IDENTITY (1, 1) NOT NULL,
    [VendorId]       [dbo].[pVendorID]    NULL,
    [ItemId]         [dbo].[pItemID]      NULL,
    [ItemType]       TINYINT              CONSTRAINT [DF__tblPoPurc__ItemT__6550D9A5] DEFAULT (0) NULL,
    [LocId]          [dbo].[pLocID]       NULL,
    [Descr]          [dbo].[pDescription] NULL,
    [Qty]            [dbo].[pDec]         CONSTRAINT [DF__tblPoPurcha__Qty__6644FDDE] DEFAULT (0) NULL,
    [UnitCost]       [dbo].[pDec]         CONSTRAINT [DF__tblPoPurc__UnitC__67392217] DEFAULT (0) NULL,
    [ExtCost]        [dbo].[pDec]         CONSTRAINT [DF__tblPoPurc__ExtCo__682D4650] DEFAULT (0) NULL,
    [Uom]            [dbo].[pUom]         NULL,
    [InitDate]       DATETIME             NULL,
    [EnteredBy]      [dbo].[pUserID]      NULL,
    [SourceApp]      VARCHAR (2)          NULL,
    [RefId]          NVARCHAR (255)       NULL,
    [GenerateYn]     BIT                  CONSTRAINT [DF__tblPoPurc__Gener__69216A89] DEFAULT (0) NULL,
    [GlAcct]         [dbo].[pGlAcct]      NULL,
    [ReqShipDate]    DATETIME             NULL,
    [AddnlDescr]     TEXT                 NULL,
    [ts]             ROWVERSION           NULL,
    [DropShipYn]     BIT                  DEFAULT ((0)) NULL,
    [LineNum]        INT                  NULL,
    [LinkSeqNum]     INT                  NULL,
    [LinkTransId]    [dbo].[pTransID]     NULL,
    [OrderReqId]     VARCHAR (4)          NULL,
    [ReleaseNum]     VARCHAR (3)          NULL,
    [Seq]            INT                  NULL,
    [SourceType]     SMALLINT             NULL,
    [CustId]         [dbo].[pCustID]      NULL,
    [PhaseId]        VARCHAR (10)         NULL,
    [ProjId]         VARCHAR (10)         NULL,
    [TaskId]         VARCHAR (10)         NULL,
    [CF]             XML                  NULL,
    [ExpReceiptDate] DATETIME             NULL,
    CONSTRAINT [PK__tblPoPurchaseReq__004002F9] PRIMARY KEY CLUSTERED ([ReqId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlVendorId]
    ON [dbo].[tblPoPurchaseReq]([VendorId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlLocId]
    ON [dbo].[tblPoPurchaseReq]([LocId] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlItemId]
    ON [dbo].[tblPoPurchaseReq]([ItemId] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoPurchaseReq';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoPurchaseReq';

