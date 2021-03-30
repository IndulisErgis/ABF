CREATE TABLE [dbo].[tblInMatReqDetail] (
    [TransId]     INT                  NOT NULL,
    [LineNum]     SMALLINT             NOT NULL,
    [ItemId]      [dbo].[pItemID]      NULL,
    [LocId]       [dbo].[pLocID]       NULL,
    [Descr]       [dbo].[pDescription] NULL,
    [UomBase]     [dbo].[pUom]         NULL,
    [UomSelling]  [dbo].[pUom]         NULL,
    [ConvFactor]  [dbo].[pDec]         CONSTRAINT [DF__tblInMatR__ConvF__360BDAD7] DEFAULT (1) NULL,
    [ItemType]    TINYINT              CONSTRAINT [DF__tblInMatR__ItemT__36FFFF10] DEFAULT (1) NULL,
    [GLAcctNum]   [dbo].[pGlAcct]      NULL,
    [GLDescr]     [dbo].[pGLDesc]      NULL,
    [QtyReqstd]   [dbo].[pDec]         CONSTRAINT [DF__tblInMatR__QtyRe__37F42349] DEFAULT (1) NULL,
    [QtyFilled]   [dbo].[pDec]         CONSTRAINT [DF__tblInMatR__QtyFi__38E84782] DEFAULT (1) NULL,
    [QtyBkord]    [dbo].[pDec]         CONSTRAINT [DF__tblInMatR__QtyBk__39DC6BBB] DEFAULT (0) NULL,
    [CostUnitStd] [dbo].[pDec]         CONSTRAINT [DF__tblInMatR__CostU__3AD08FF4] DEFAULT (0) NULL,
    [JOJobId]     VARCHAR (10)         NULL,
    [JOPhaseId]   VARCHAR (10)         NULL,
    [JOCostCode]  VARCHAR (3)          NULL,
    [HistSeqNum]  INT                  NULL,
    [Status]      VARCHAR (15)         NULL,
    [CustId]      [dbo].[pCustID]      NULL,
    [ProjId]      VARCHAR (10)         NULL,
    [PhaseId]     VARCHAR (10)         NULL,
    [ProjName]    VARCHAR (30)         NULL,
    [PhaseName]   VARCHAR (30)         NULL,
    [TaskName]    VARCHAR (30)         NULL,
    [TaskId]      VARCHAR (10)         NULL,
    [QtySeqNum]   INT                  NULL,
    [ts]          ROWVERSION           NULL,
    [CF]          XML                  NULL,
    [LineSeq]     INT                  NULL,
    CONSTRAINT [PK__tblInMatReqDetai__269AB60B] PRIMARY KEY CLUSTERED ([TransId] ASC, [LineNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInMatReqDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblInMatReqDetail';

