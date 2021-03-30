CREATE TABLE [dbo].[tblPaEmpExclude] (
    [WithholdId]        INT        NOT NULL,
    [TaxAuthorityDtlId] INT        NOT NULL,
    [ts]                ROWVERSION NULL,
    CONSTRAINT [PK_tblPaEmpExclude] PRIMARY KEY CLUSTERED ([WithholdId] ASC, [TaxAuthorityDtlId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpExclude';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpExclude';

