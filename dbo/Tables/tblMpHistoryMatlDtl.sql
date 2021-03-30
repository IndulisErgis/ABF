CREATE TABLE [dbo].[tblMpHistoryMatlDtl] (
    [PostRun]             [dbo].[pPostRun] NOT NULL,
    [TransId]             INT              NOT NULL,
    [SeqNo]               INT              DEFAULT ((0)) NOT NULL,
    [TransDate]           DATETIME         NULL,
    [ComponentId]         [dbo].[pItemID]  NULL,
    [LocId]               [dbo].[pLocID]   NULL,
    [Qty]                 [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [UOM]                 [dbo].[pUom]     NULL,
    [ConvFactor]          [dbo].[pDec]     DEFAULT ((1)) NOT NULL,
    [ActualScrap]         [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [UnitCost]            [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [VarianceCode]        VARCHAR (10)     NULL,
    [AssembledYn]         INT              NOT NULL,
    [SubAssemblyTranType] SMALLINT         DEFAULT ((0)) NOT NULL,
    [GlPeriod]            SMALLINT         DEFAULT ((0)) NOT NULL,
    [FiscalYear]          SMALLINT         DEFAULT ((0)) NOT NULL,
    [SumHistPeriod]       SMALLINT         DEFAULT ((1)) NULL,
    [HistSeqNum]          INT              DEFAULT ((0)) NOT NULL,
    [QtySeqNum]           INT              DEFAULT ((0)) NULL,
    [Notes]               TEXT             NULL,
    [ts]                  ROWVERSION       NULL,
    [CF]                  XML              NULL,
    [UOMBase]             [dbo].[pUom]     NULL,
    CONSTRAINT [PK_tblMpHistoryMatlDtl] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [SeqNo] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryMatlDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryMatlDtl';

