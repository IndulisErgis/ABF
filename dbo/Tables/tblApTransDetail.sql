CREATE TABLE [dbo].[tblApTransDetail] (
    [TransID]          [dbo].[pTransID]     NOT NULL,
    [EntryNum]         INT                  NOT NULL,
    [PartId]           [dbo].[pItemID]      NULL,
    [PartType]         TINYINT              CONSTRAINT [DF__tblApTran__PartT__1EE87E5D] DEFAULT (0) NULL,
    [WhseId]           [dbo].[pLocID]       NULL,
    [Desc]             [dbo].[pDescription] NULL,
    [CostType]         VARCHAR (6)          NULL,
    [GLAcct]           [dbo].[pGlAcct]      NULL,
    [Qty]              [dbo].[pDec]         CONSTRAINT [DF__tblApTransD__Qty__1FDCA296] DEFAULT (0) NULL,
    [QtyBase]          [dbo].[pDec]         CONSTRAINT [DF__tblApTran__QtyBa__20D0C6CF] DEFAULT (0) NULL,
    [Units]            [dbo].[pUom]         NULL,
    [UnitsBase]        [dbo].[pUom]         NULL,
    [UnitCost]         [dbo].[pDec]         CONSTRAINT [DF__tblApTran__UnitC__21C4EB08] DEFAULT (0) NULL,
    [UnitCostFgn]      [dbo].[pDec]         CONSTRAINT [DF__tblApTran__UnitC__22B90F41] DEFAULT (0) NULL,
    [ExtCost]          [dbo].[pDec]         CONSTRAINT [DF__tblApTran__ExtCo__23AD337A] DEFAULT (0) NULL,
    [ExtCostFgn]       [dbo].[pDec]         CONSTRAINT [DF__tblApTran__ExtCo__24A157B3] DEFAULT (0) NULL,
    [GLDesc]           [dbo].[pGLDesc]      NULL,
    [AddnlDesc]        TEXT                 NULL,
    [HistSeqNum]       INT                  CONSTRAINT [DF__tblApTran__HistS__25957BEC] DEFAULT (0) NULL,
    [TaxClass]         TINYINT              CONSTRAINT [DF__tblApTran__TaxCl__2689A025] DEFAULT (0) NULL,
    [BinNum]           VARCHAR (10)         NULL,
    [ConversionFactor] [dbo].[pDec]         CONSTRAINT [DF__tblApTran__Conve__277DC45E] DEFAULT (1) NULL,
    [LottedYN]         BIT                  CONSTRAINT [DF__tblApTran__Lotte__2871E897] DEFAULT (0) NULL,
    [InItemYN]         BIT                  CONSTRAINT [DF__tblApTran__InIte__29660CD0] DEFAULT (0) NULL,
    [GLAcctSales]      [dbo].[pGlAcct]      NULL,
    [TransHistId]      VARCHAR (10)         NULL,
    [ExtInc]           [dbo].[pDec]         NULL,
    [GLAcctWIP]        [dbo].[pGlAcct]      NULL,
    [CustomerID]       [dbo].[pCustID]      NULL,
    [JobId]            VARCHAR (10)         NULL,
    [ProjName]         VARCHAR (30)         NULL,
    [PhaseId]          VARCHAR (10)         NULL,
    [PhaseName]        VARCHAR (30)         NULL,
    [TaskId]           VARCHAR (10)         NULL,
    [TaskName]         VARCHAR (30)         NULL,
    [UnitInc]          [dbo].[pDec]         NULL,
    [QtySeqNum]        INT                  CONSTRAINT [DF_tblApTransDetail_QtySeqNum] DEFAULT (0) NULL,
    [ts]               ROWVERSION           NULL,
    [LineSeq]          INT                  NULL,
    [CF]               XML                  NULL,
    CONSTRAINT [PK_tblApTransDetail] PRIMARY KEY CLUSTERED ([TransID] ASC, [EntryNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransDetail';

