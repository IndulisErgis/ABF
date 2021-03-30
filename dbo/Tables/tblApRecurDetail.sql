CREATE TABLE [dbo].[tblApRecurDetail] (
    [RecurID]   VARCHAR (10)         NOT NULL,
    [EntryNum]  INT                  NOT NULL,
    [PartId]    [dbo].[pItemID]      NULL,
    [PartType]  TINYINT              CONSTRAINT [DF__tblApRecu__PartT__51A90854] DEFAULT (0) NULL,
    [Desc]      [dbo].[pDescription] NULL,
    [JobId]     VARCHAR (10)         NULL,
    [PhaseId]   VARCHAR (10)         NULL,
    [CostType]  VARCHAR (6)          NULL,
    [GLAcct]    [dbo].[pGlAcct]      NULL,
    [Qty]       [dbo].[pDec]         CONSTRAINT [DF__tblApRecurD__Qty__529D2C8D] DEFAULT (0) NULL,
    [QtyBase]   [dbo].[pDec]         CONSTRAINT [DF__tblApRecu__QtyBa__539150C6] DEFAULT (0) NULL,
    [Units]     [dbo].[pUom]         NULL,
    [UnitsBase] [dbo].[pUom]         NULL,
    [UnitCost]  [dbo].[pDec]         CONSTRAINT [DF__tblApRecu__UnitC__548574FF] DEFAULT (0) NULL,
    [ExtCost]   [dbo].[pDec]         CONSTRAINT [DF__tblApRecu__ExtCo__55799938] DEFAULT (0) NULL,
    [GLDesc]    [dbo].[pGLDesc]      NULL,
    [AddnlDesc] TEXT                 NULL,
    [ts]        ROWVERSION           NULL,
    [TaxClass]  TINYINT              CONSTRAINT [DF_tblApRecurDetail_TaxClass] DEFAULT (0) NULL,
    [LineSeq]   INT                  NULL,
    [CF]        XML                  NULL,
    CONSTRAINT [PK_tblApRecurDetail] PRIMARY KEY CLUSTERED ([RecurID] ASC, [EntryNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApRecurDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApRecurDetail';

