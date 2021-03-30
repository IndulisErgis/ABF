CREATE TABLE [dbo].[tblPaTaxAuthorityDetail] (
    [Id]                 INT             NOT NULL,
    [TaxAuthorityId]     INT             NOT NULL,
    [PaYear]             SMALLINT        NOT NULL,
    [Code]               [dbo].[pCode]   NOT NULL,
    [EmployerPaid]       BIT             NOT NULL,
    [Description]        NVARCHAR (30)   NULL,
    [FormulaId]          NVARCHAR (12)   NULL,
    [CodeType]           TINYINT         NOT NULL,
    [GlLiabilityAccount] [dbo].[pGlAcct] NULL,
    [TaxId]              NVARCHAR (17)   NULL,
    [FixedPercent]       [dbo].[pDec]    CONSTRAINT [DF_tblPaTaxAuthorityDetail_FixedPercent] DEFAULT ((0)) NOT NULL,
    [EmplrExpenseAcct]   [dbo].[pGlAcct] NULL,
    [WeeksWorkedLimit]   [dbo].[pDec]    CONSTRAINT [DF_tblPaTaxAuthorityDetail_WeeksWorkedLimit] DEFAULT ((0)) NOT NULL,
    [TaxType]            INT             NULL,
    [CF]                 XML             NULL,
    [ts]                 ROWVERSION      NULL,
    CONSTRAINT [PK_tblPaTaxAuthorityDetail] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaTaxAuthorityDetail_TaxAuthorityIdPaYearCodeEmployerPaid]
    ON [dbo].[tblPaTaxAuthorityDetail]([TaxAuthorityId] ASC, [PaYear] ASC, [Code] ASC, [EmployerPaid] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxAuthorityDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaTaxAuthorityDetail';

