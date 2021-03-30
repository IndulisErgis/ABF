CREATE TABLE [dbo].[tblBmWorkOrderHist] (
    [PostRun]       [dbo].[pPostRun]     CONSTRAINT [DF__tblBmWork__PostR__6B99EBCE] DEFAULT (0) NOT NULL,
    [TransId]       [dbo].[pTransID]     NOT NULL,
    [EntryNum]      INT                  CONSTRAINT [DF_tblBmWorkOrderHist_EntryNum] DEFAULT ((-1)) NOT NULL,
    [TransDate]     DATETIME             CONSTRAINT [DF__tblBmWork__Trans__6D823440] DEFAULT (getdate()) NULL,
    [WorkType]      TINYINT              CONSTRAINT [DF__tblBmWork__WorkT__6E765879] DEFAULT (1) NULL,
    [Status]        TINYINT              CONSTRAINT [DF__tblBmWork__Statu__6F6A7CB2] DEFAULT (0) NOT NULL,
    [PrintedYn]     BIT                  CONSTRAINT [DF__tblBmWork__Print__705EA0EB] DEFAULT (0) NOT NULL,
    [BmBomId]       INT                  NULL,
    [ItemId]        [dbo].[pItemID]      NULL,
    [LocId]         [dbo].[pLocID]       NULL,
    [ItemType]      TINYINT              NULL,
    [BuildUOM]      [dbo].[pUom]         NULL,
    [BuildQty]      [dbo].[pDec]         CONSTRAINT [DF__tblBmWork__Build__7152C524] DEFAULT (0) NULL,
    [ActualQty]     [dbo].[pDec]         CONSTRAINT [DF__tblBmWork__Actua__7246E95D] DEFAULT (0) NULL,
    [LaborCost]     [dbo].[pDec]         CONSTRAINT [DF__tblBmWork__Labor__733B0D96] DEFAULT (0) NULL,
    [UnitCost]      [dbo].[pDec]         CONSTRAINT [DF__tblBmWork__UnitC__742F31CF] DEFAULT (0) NULL,
    [ConvFactor]    [dbo].[pDec]         CONSTRAINT [DF__tblBmWork__ConvF__75235608] DEFAULT (1) NULL,
    [GLPeriod]      SMALLINT             CONSTRAINT [DF__tblBmWork__GLPer__76177A41] DEFAULT (0) NULL,
    [GlYear]        SMALLINT             CONSTRAINT [DF__tblBmWork__GlYea__770B9E7A] DEFAULT (0) NULL,
    [SumHistPeriod] SMALLINT             CONSTRAINT [DF__tblBmWork__SumHi__77FFC2B3] DEFAULT (0) NULL,
    [QtySeqNum]     INT                  CONSTRAINT [DF__tblBmWork__QtySe__78F3E6EC] DEFAULT (0) NULL,
    [HistSeqNum]    INT                  CONSTRAINT [DF__tblBmWork__HistS__79E80B25] DEFAULT (0) NULL,
    [WorkUser]      [dbo].[pUserID]      NULL,
    [Descr]         [dbo].[pDescription] NULL,
    [UomBase]       [dbo].[pUom]         NULL,
    [ItemStatus]    TINYINT              NULL,
    [ItemLocStatus] TINYINT              NULL,
    [GLAcctCode]    [dbo].[pGLAcctCode]  NULL,
    [ts]            ROWVERSION           NULL,
    [CF]            XML                  NULL,
    CONSTRAINT [PK__tblBmWorkOrderHist] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBmWorkOrderHist';

