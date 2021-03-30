CREATE TABLE [dbo].[tblPsCountDetail] (
    [ID]         BIGINT            NOT NULL,
    [CountID]    BIGINT            NOT NULL,
    [CountGroup] DATETIME          NOT NULL,
    [CountType]  TINYINT           NOT NULL,
    [UserID]     BIGINT            NOT NULL,
    [TenderID]   BIGINT            NOT NULL,
    [Quantity]   INT               NOT NULL,
    [Value]      [dbo].[pDecimal]  NOT NULL,
    [CurrencyID] [dbo].[pCurrency] NOT NULL,
    [CF]         XML               NULL,
    [ts]         ROWVERSION        NULL,
    CONSTRAINT [PK_tblPsCountDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsCountDetail_CountGroup]
    ON [dbo].[tblPsCountDetail]([CountGroup] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsCountDetail_CountID]
    ON [dbo].[tblPsCountDetail]([CountID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsCountDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsCountDetail';

