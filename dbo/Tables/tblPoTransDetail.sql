CREATE TABLE [dbo].[tblPoTransDetail] (
    [TransID]               [dbo].[pTransID]     NOT NULL,
    [EntryNum]              INT                  NOT NULL,
    [QtyOrd]                [dbo].[pDec]         CONSTRAINT [DF__tblPoTran__QtyOr__0004CFE1] DEFAULT (0) NULL,
    [UnitCost]              [dbo].[pDec]         CONSTRAINT [DF__tblPoTran__UnitC__00F8F41A] DEFAULT (0) NULL,
    [UnitCostFgn]           [dbo].[pDec]         CONSTRAINT [DF__tblPoTran__UnitC__01ED1853] DEFAULT (0) NULL,
    [ExtCost]               [dbo].[pDec]         CONSTRAINT [DF__tblPoTran__ExtCo__02E13C8C] DEFAULT (0) NULL,
    [ExtCostFgn]            [dbo].[pDec]         CONSTRAINT [DF__tblPoTran__ExtCo__03D560C5] DEFAULT (0) NULL,
    [ItemId]                [dbo].[pItemID]      NULL,
    [ItemType]              TINYINT              CONSTRAINT [DF__tblPoTran__ItemT__04C984FE] DEFAULT (0) NULL,
    [LocId]                 [dbo].[pLocID]       NULL,
    [Descr]                 [dbo].[pDescription] NULL,
    [UnitsBase]             [dbo].[pUom]         NULL,
    [Units]                 [dbo].[pUom]         NULL,
    [LineStatus]            TINYINT              CONSTRAINT [DF__tblPoTran__LineS__05BDA937] DEFAULT (0) NULL,
    [GLDesc]                [dbo].[pGLDesc]      NULL,
    [AddnlDescr]            TEXT                 NULL,
    [TaxClass]              TINYINT              CONSTRAINT [DF__tblPoTran__TaxCl__06B1CD70] DEFAULT (0) NULL,
    [BinNum]                VARCHAR (10)         NULL,
    [ConversionFactor]      [dbo].[pDec]         CONSTRAINT [DF__tblPoTran__Conve__07A5F1A9] DEFAULT (1) NULL,
    [LottedYN]              BIT                  CONSTRAINT [DF__tblPoTran__Lotte__089A15E2] DEFAULT (0) NULL,
    [InItemYN]              BIT                  CONSTRAINT [DF__tblPoTran__InIte__098E3A1B] DEFAULT (1) NULL,
    [ReqShipDate]           DATETIME             CONSTRAINT [DF__tblPoTran__ReqSh__0A825E54] DEFAULT (getdate()) NULL,
    [GLAcct]                [dbo].[pGlAcct]      NULL,
    [GLAcctSales]           [dbo].[pGlAcct]      NULL,
    [GLAcctWIP]             [dbo].[pGlAcct]      NULL,
    [TransHistID]           VARCHAR (10)         NULL,
    [CustID]                [dbo].[pCustID]      NULL,
    [ProjID]                VARCHAR (10)         NULL,
    [ProjName]              VARCHAR (30)         NULL,
    [PhaseId]               VARCHAR (10)         NULL,
    [PhaseName]             VARCHAR (30)         NULL,
    [TaskID]                VARCHAR (10)         NULL,
    [TaskName]              VARCHAR (30)         NULL,
    [UnitInc]               [dbo].[pDec]         CONSTRAINT [DF__tblPoTran__UnitI__0B76828D] DEFAULT (0) NULL,
    [ExtInc]                [dbo].[pDec]         CONSTRAINT [DF__tblPoTran__ExtIn__0C6AA6C6] DEFAULT (0) NULL,
    [ProjItemYn]            BIT                  CONSTRAINT [DF__tblPoTran__ProjI__0D5ECAFF] DEFAULT (0) NULL,
    [QtySeqNum]             INT                  CONSTRAINT [DF_tblPoTransDetail_QtySeqNum] DEFAULT (0) NULL,
    [ts]                    ROWVERSION           NULL,
    [LandedCostID]          VARCHAR (10)         NULL,
    [LineNum]               INT                  NULL,
    [LineSeq]               INT                  NULL,
    [LinkSeqNum]            INT                  NULL,
    [LinkTransId]           [dbo].[pTransID]     NULL,
    [ReleaseNum]            VARCHAR (3)          NULL,
    [ReqId]                 VARCHAR (4)          NULL,
    [Seq]                   INT                  NULL,
    [SourceType]            SMALLINT             NULL,
    [TransHistIDLandedCost] VARCHAR (10)         NULL,
    [CF]                    XML                  NULL,
    [Type]                  TINYINT              NULL,
    [ProjectDetailId]       INT                  NULL,
    [ActivityId]            INT                  NULL,
    [GLAcctAccrual]         [dbo].[pGlAcct]      NULL,
    [ExpReceiptDate]        DATETIME             NULL,
    CONSTRAINT [PK_tblPoTransDetail] PRIMARY KEY CLUSTERED ([TransID] ASC, [EntryNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlTransHistID]
    ON [dbo].[tblPoTransDetail]([TransHistID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlTaskID]
    ON [dbo].[tblPoTransDetail]([TaskID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlCustID]
    ON [dbo].[tblPoTransDetail]([CustID] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoTransDetail';

