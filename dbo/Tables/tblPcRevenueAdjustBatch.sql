CREATE TABLE [dbo].[tblPcRevenueAdjustBatch] (
    [ID]            BIGINT           NOT NULL,
    [BatchID]       [dbo].[pBatchID] NOT NULL,
    [FiscalPeriod]  SMALLINT         NOT NULL,
    [FiscalYear]    SMALLINT         NOT NULL,
    [Filter]        NVARCHAR (MAX)   NULL,
    [DisplayFilter] NVARCHAR (MAX)   NULL,
    [CF]            XML              NULL,
    [ts]            ROWVERSION       NULL,
    CONSTRAINT [PK_tblPcRevenueAdjustBatch] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPcRevenueAdjustBatch_BatchID]
    ON [dbo].[tblPcRevenueAdjustBatch]([BatchID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcRevenueAdjustBatch';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcRevenueAdjustBatch';

