CREATE TABLE [dbo].[tblMpHistorySubContractDtl] (
    [PostRun]       [dbo].[pPostRun]  NOT NULL,
    [TransId]       INT               NOT NULL,
    [SeqNo]         INT               DEFAULT ((0)) NOT NULL,
    [TransDate]     DATETIME          NULL,
    [QtySent]       [dbo].[pDec]      DEFAULT ((0)) NOT NULL,
    [QtyReceived]   [dbo].[pDec]      DEFAULT ((0)) NOT NULL,
    [QtyScrapped]   [dbo].[pDec]      DEFAULT ((0)) NOT NULL,
    [UnitCost]      [dbo].[pDec]      DEFAULT ((0)) NOT NULL,
    [VendorId]      [dbo].[pVendorID] NULL,
    [VendorDocNo]   VARCHAR (30)      NULL,
    [VarianceCode]  VARCHAR (10)      NULL,
    [GlPeriod]      SMALLINT          DEFAULT ((0)) NOT NULL,
    [FiscalYear]    SMALLINT          DEFAULT ((0)) NOT NULL,
    [SumHistPeriod] SMALLINT          DEFAULT ((1)) NULL,
    [Notes]         TEXT              NULL,
    [ts]            ROWVERSION        NULL,
    [CF]            XML               NULL,
    CONSTRAINT [PK_tblMpHistorySubContractDtl] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [SeqNo] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistorySubContractDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistorySubContractDtl';

