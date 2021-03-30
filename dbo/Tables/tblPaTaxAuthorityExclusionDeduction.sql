CREATE TABLE [dbo].[tblPaTaxAuthorityExclusionDeduction] (
    [TaxAuthorityDtlId] INT        NOT NULL,
    [DeductionCodeId]   INT        NOT NULL,
    [ts]                ROWVERSION NULL,
    CONSTRAINT [PK_tblPaTaxAuthorityExclusionDeduction] PRIMARY KEY CLUSTERED ([TaxAuthorityDtlId] ASC, [DeductionCodeId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxAuthorityExclusionDeduction';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxAuthorityExclusionDeduction';

