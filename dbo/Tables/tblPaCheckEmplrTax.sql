CREATE TABLE [dbo].[tblPaCheckEmplrTax] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [CheckId]             INT             NOT NULL,
    [DepartmentId]        [dbo].[pDeptID] NULL,
    [TaxAuthorityId]      INT             NOT NULL,
    [TaxAuthorityDtlId]   INT             NOT NULL,
    [WithholdingCode]     [dbo].[pCode]   NULL,
    [Description]         NVARCHAR (30)   NULL,
    [WithholdingPayments] [dbo].[pDec]    CONSTRAINT [DF_tblPaCheckEmplrTax_WithholdingPayments] DEFAULT ((0)) NOT NULL,
    [WithholdingEarnings] [dbo].[pDec]    CONSTRAINT [DF_tblPaCheckEmplrTax_WithholdingEarnings] DEFAULT ((0)) NOT NULL,
    [GrossEarnings]       [dbo].[pDec]    CONSTRAINT [DF_tblPaCheckEmplrTax_GrossEarnings] DEFAULT ((0)) NOT NULL,
    [CF]                  XML             NULL,
    [ts]                  ROWVERSION      NULL,
    CONSTRAINT [PK_tblPaCheckEmplrTax] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckEmplrTax_DepartmentId]
    ON [dbo].[tblPaCheckEmplrTax]([DepartmentId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaCheckEmplrTax_CheckId]
    ON [dbo].[tblPaCheckEmplrTax]([CheckId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckEmplrTax';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckEmplrTax';

