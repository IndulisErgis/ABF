CREATE TABLE [dbo].[tblApHistDetail] (
    [PostRun]          [dbo].[pPostRun]     CONSTRAINT [DF__tblApHist__PostR__1999B95B] DEFAULT (0) NOT NULL,
    [TransID]          [dbo].[pTransID]     NOT NULL,
    [InvoiceNum]       [dbo].[pInvoiceNum]  NOT NULL,
    [EntryNum]         INT                  NOT NULL,
    [PartId]           [dbo].[pItemID]      NULL,
    [PartType]         TINYINT              CONSTRAINT [DF__tblApHist__PartT__1B8201CD] DEFAULT (0) NULL,
    [WhseId]           [dbo].[pLocID]       NULL,
    [Desc]             [dbo].[pDescription] NULL,
    [Qty]              [dbo].[pDec]         CONSTRAINT [DF__tblApHistDe__Qty__1C762606] DEFAULT (0) NULL,
    [QtyBase]          [dbo].[pDec]         CONSTRAINT [DF__tblApHist__QtyBa__1D6A4A3F] DEFAULT (0) NULL,
    [Units]            [dbo].[pUom]         NULL,
    [UnitsBase]        [dbo].[pUom]         NULL,
    [UnitCost]         [dbo].[pDec]         CONSTRAINT [DF__tblApHist__UnitC__1E5E6E78] DEFAULT (0) NULL,
    [UnitCostFgn]      [dbo].[pDec]         CONSTRAINT [DF__tblApHist__UnitC__1F5292B1] DEFAULT (0) NULL,
    [ExtCost]          [dbo].[pDec]         CONSTRAINT [DF__tblApHist__ExtCo__2046B6EA] DEFAULT (0) NULL,
    [ExtCostFgn]       [dbo].[pDec]         CONSTRAINT [DF__tblApHist__ExtCo__213ADB23] DEFAULT (0) NULL,
    [GLDesc]           [dbo].[pGLDesc]      NULL,
    [AddnlDesc]        TEXT                 NULL,
    [HistSeqNum]       INT                  CONSTRAINT [DF__tblApHist__HistS__222EFF5C] DEFAULT (0) NULL,
    [TaxClass]         TINYINT              CONSTRAINT [DF__tblApHist__TaxCl__23232395] DEFAULT (0) NULL,
    [BinNum]           VARCHAR (10)         NULL,
    [ConversionFactor] [dbo].[pDec]         CONSTRAINT [DF__tblApHist__Conve__241747CE] DEFAULT (1) NULL,
    [LottedYN]         BIT                  CONSTRAINT [DF__tblApHist__Lotte__250B6C07] DEFAULT (0) NULL,
    [InItemYN]         BIT                  CONSTRAINT [DF__tblApHist__InIte__25FF9040] DEFAULT (0) NULL,
    [GLAcct]           [dbo].[pGlAcct]      NULL,
    [GLAcctWIP]        [dbo].[pGlAcct]      NULL,
    [GLAcctSales]      [dbo].[pGlAcct]      NULL,
    [TransHistId]      VARCHAR (10)         NULL,
    [CustomerID]       [dbo].[pCustID]      NULL,
    [JobId]            VARCHAR (10)         NULL,
    [ProjName]         VARCHAR (30)         NULL,
    [PhaseId]          VARCHAR (10)         NULL,
    [PhaseName]        VARCHAR (30)         NULL,
    [TaskId]           VARCHAR (10)         NULL,
    [TaskName]         VARCHAR (30)         NULL,
    [UnitInc]          [dbo].[pDec]         NULL,
    [ExtInc]           [dbo].[pDec]         NULL,
    [ProjItemYn]       BIT                  CONSTRAINT [DF__tblApHist__ProjI__26F3B479] DEFAULT (0) NULL,
    [CostType]         VARCHAR (6)          NULL,
    [LineSeq]          INT                  NULL,
    [CF]               XML                  NULL,
    CONSTRAINT [PK_tblApHistDetail] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransID] ASC, [InvoiceNum] ASC, [EntryNum] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblApHistDetail] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblApHistDetail] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblApHistDetail] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblApHistDetail] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistDetail';

