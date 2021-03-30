CREATE TABLE [dbo].[tblMpMatlDtl] (
    [TransId]             INT             NOT NULL,
    [SeqNo]               INT             IDENTITY (1, 1) NOT NULL,
    [TransDate]           DATETIME        NULL,
    [ComponentID]         [dbo].[pItemID] NULL,
    [LocID]               [dbo].[pLocID]  NULL,
    [Qty]                 [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [UOM]                 [dbo].[pUom]    NULL,
    [ConvFactor]          [dbo].[pDec]    DEFAULT ((1)) NOT NULL,
    [ActualScrap]         [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [UnitCost]            [dbo].[pDec]    DEFAULT ((0)) NOT NULL,
    [VarianceCode]        VARCHAR (10)    NULL,
    [AssembledYn]         INT             NOT NULL,
    [SubAssemblyTranType] SMALLINT        DEFAULT ((0)) NOT NULL,
    [GlPeriod]            SMALLINT        DEFAULT ((0)) NOT NULL,
    [FiscalYear]          SMALLINT        DEFAULT ((0)) NOT NULL,
    [SumHistPeriod]       SMALLINT        DEFAULT ((1)) NULL,
    [HistSeqNum]          INT             DEFAULT ((0)) NOT NULL,
    [QtySeqNum]           INT             DEFAULT ((0)) NULL,
    [Notes]               TEXT            NULL,
    [ts]                  ROWVERSION      NULL,
    [CF]                  XML             NULL,
    CONSTRAINT [PK_tblMpMatlDtl] PRIMARY KEY CLUSTERED ([SeqNo] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblMpMatlDtl_TransId]
    ON [dbo].[tblMpMatlDtl]([TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpMatlDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpMatlDtl';

