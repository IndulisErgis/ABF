CREATE TABLE [dbo].[tblPsCountExchangeRate] (
    [ID]         BIGINT            NOT NULL,
    [CountID]    BIGINT            NOT NULL,
    [CurrencyID] [dbo].[pCurrency] NOT NULL,
    [Rate]       [dbo].[pDecimal]  NOT NULL,
    [CF]         XML               NULL,
    [ts]         ROWVERSION        NULL,
    CONSTRAINT [PK_tblPsCountExchangeRate] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsCountExchangeRate_CountIDCurrencyID]
    ON [dbo].[tblPsCountExchangeRate]([CountID] ASC, [CurrencyID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsCountExchangeRate';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsCountExchangeRate';

