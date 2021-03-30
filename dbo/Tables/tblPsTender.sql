CREATE TABLE [dbo].[tblPsTender] (
    [ID]          BIGINT               NOT NULL,
    [Description] [dbo].[pDescription] NOT NULL,
    [Type]        TINYINT              NOT NULL,
    [Value]       [dbo].[pDecimal]     NULL,
    [CurrencyID]  [dbo].[pCurrency]    NOT NULL,
    [PmtMethodID] NVARCHAR (10)        NULL,
    [CF]          XML                  NULL,
    [ts]          ROWVERSION           NULL,
    CONSTRAINT [PK_tblPsTender] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPsTender_Description]
    ON [dbo].[tblPsTender]([Description] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTender';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsTender';

