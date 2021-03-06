CREATE TABLE [dbo].[tblPaTaxAuthorityExclusionEarning] (
    [TaxAuthorityDtlId] INT           NOT NULL,
    [EarningCodeId]     [dbo].[pCode] NOT NULL,
    [ts]                ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaTaxAuthorityExclusionEarning] PRIMARY KEY CLUSTERED ([TaxAuthorityDtlId] ASC, [EarningCodeId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxAuthorityExclusionEarning';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxAuthorityExclusionEarning';

