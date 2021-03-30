CREATE TABLE [dbo].[tblPaEmpWithhold] (
    [Id]               INT            NOT NULL,
    [EmployeeId]       [dbo].[pEmpID] NOT NULL,
    [PaYear]           SMALLINT       NOT NULL,
    [TaxAuthorityId]   INT            NOT NULL,
    [MaritalStatus]    NVARCHAR (3)   NULL,
    [Exemptions]       TINYINT        CONSTRAINT [DF_tblPaEmpWithhold_Exemptions] DEFAULT ((0)) NOT NULL,
    [ExtraWithholding] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpWithhold_ExtraWithholding] DEFAULT ((0)) NOT NULL,
    [FixedWithholding] [dbo].[pDec]   CONSTRAINT [DF_tblPaEmpWithhold_FixedWithholding] DEFAULT ((0)) NOT NULL,
    [HomeState]        NCHAR (2)      NULL,
    [DefaultWH]        BIT            CONSTRAINT [DF_tblPaEmpWithhold_DefaultWH] DEFAULT ((0)) NOT NULL,
    [SUIState]         NVARCHAR (2)   NULL,
    [EICCode]          NVARCHAR (1)   NULL,
    [CF]               XML            NULL,
    [ts]               ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaEmpWithhold] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaEmpWithhold_EmployeeIdPaYearTaxAuthorityId]
    ON [dbo].[tblPaEmpWithhold]([EmployeeId] ASC, [PaYear] ASC, [TaxAuthorityId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpWithhold';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpWithhold';

