CREATE TABLE [dbo].[tblPcWIPControl] (
    [BatchId]             [dbo].[pBatchID]  NOT NULL,
    [CurrencyId]          [dbo].[pCurrency] NOT NULL,
    [FiscalYear]          SMALLINT          NOT NULL,
    [FiscalPeriod]        SMALLINT          NOT NULL,
    [ExchRate]            [dbo].[pDec]      CONSTRAINT [DF_tblPcWIPControl_ExchRate] DEFAULT ((1)) NOT NULL,
    [Filter]              NVARCHAR (MAX)    NULL,
    [ConsolidatedBilling] BIT               CONSTRAINT [DF_tblPcWIPControl_ConsolidatedBilling] DEFAULT ((0)) NOT NULL,
    [CF]                  XML               NULL,
    [ts]                  ROWVERSION        NULL,
    CONSTRAINT [PK_tblPcWIPControl] PRIMARY KEY CLUSTERED ([BatchId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcWIPControl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPcWIPControl';

