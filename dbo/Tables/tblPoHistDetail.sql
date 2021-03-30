CREATE TABLE [dbo].[tblPoHistDetail] (
    [PostRun]               [dbo].[pPostRun]     NOT NULL,
    [TransID]               [dbo].[pTransID]     NOT NULL,
    [EntryNum]              INT                  NOT NULL,
    [QtyOrd]                [dbo].[pDec]         NULL,
    [UnitCost]              [dbo].[pDec]         NULL,
    [UnitCostFgn]           [dbo].[pDec]         NULL,
    [ExtCost]               [dbo].[pDec]         NULL,
    [ExtCostFgn]            [dbo].[pDec]         NULL,
    [ItemId]                [dbo].[pItemID]      NULL,
    [ItemType]              TINYINT              NULL,
    [LocId]                 [dbo].[pLocID]       NULL,
    [Descr]                 [dbo].[pDescription] NULL,
    [UnitsBase]             [dbo].[pUom]         NULL,
    [Units]                 [dbo].[pUom]         NULL,
    [LineStatus]            TINYINT              NULL,
    [GLDesc]                [dbo].[pGLDesc]      NULL,
    [AddnlDescr]            TEXT                 NULL,
    [TaxClass]              TINYINT              NULL,
    [BinNum]                VARCHAR (10)         NULL,
    [ConversionFactor]      [dbo].[pDec]         NULL,
    [LottedYN]              BIT                  NULL,
    [InItemYN]              BIT                  NULL,
    [ReqShipDate]           DATETIME             NULL,
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
    [UnitInc]               [dbo].[pDec]         NULL,
    [ExtInc]                [dbo].[pDec]         NULL,
    [ProjItemYn]            BIT                  NULL,
    [QtySeqNum]             INT                  NULL,
    [SourceType]            SMALLINT             NULL,
    [LineNum]               INT                  NULL,
    [LinkTransId]           [dbo].[pTransID]     NULL,
    [Seq]                   INT                  NULL,
    [ReleaseNum]            VARCHAR (3)          NULL,
    [ReqId]                 VARCHAR (4)          NULL,
    [LandedCostID]          VARCHAR (10)         NULL,
    [LineSeq]               INT                  NULL,
    [TransHistIDLandedCost] VARCHAR (10)         NULL,
    [CF]                    XML                  NULL,
    [LinkSeqNum]            INT                  NULL,
    [Type]                  TINYINT              NULL,
    [ProjectDetailId]       INT                  NULL,
    [ActivityId]            INT                  NULL,
    [GLAcctAccrual]         [dbo].[pGlAcct]      NULL,
    [ExpReceiptDate]        DATETIME             NULL,
    CONSTRAINT [PK_tblPoHistDetail] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransID] ASC, [EntryNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlTransHistID]
    ON [dbo].[tblPoHistDetail]([TransHistID] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlTaskID]
    ON [dbo].[tblPoHistDetail]([TaskID] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlCustID]
    ON [dbo].[tblPoHistDetail]([CustID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistDetail';

