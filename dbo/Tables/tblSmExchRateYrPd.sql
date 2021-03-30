CREATE TABLE [dbo].[tblSmExchRateYrPd] (
    [Counter]      INT               IDENTITY (1, 1) NOT NULL,
    [CurrencyFrom] [dbo].[pCurrency] NOT NULL,
    [CurrencyTo]   [dbo].[pCurrency] NOT NULL,
    [ExchRate]     [dbo].[pDec]      CONSTRAINT [DF_tblSmExchRateYrPd_ExchRate] DEFAULT ((0)) NOT NULL,
    [FiscalYear]   SMALLINT          NOT NULL,
    [GlPeriod]     SMALLINT          NOT NULL,
    [Notes]        NVARCHAR (50)     NULL,
    [ts]           ROWVERSION        NULL,
    CONSTRAINT [PK_tblSmExchRateYrPd] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UC_tblSmExchRateYrPd]
    ON [dbo].[tblSmExchRateYrPd]([CurrencyFrom] ASC, [CurrencyTo] ASC, [FiscalYear] ASC, [GlPeriod] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmExchRateYrPd';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmExchRateYrPd';

