CREATE TABLE [dbo].[tblPaEmpOverrideFactors] (
    [WithholdId]        INT          NOT NULL,
    [TaxAuthorityDtlId] INT          NOT NULL,
    [OverrideFactor1]   [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor1] DEFAULT ((0)) NOT NULL,
    [OverrideFactor2]   [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor2] DEFAULT ((0)) NOT NULL,
    [OverrideFactor3]   [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor3] DEFAULT ((0)) NOT NULL,
    [OverrideFactor4]   [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor4] DEFAULT ((0)) NOT NULL,
    [OverrideFactor5]   [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor5] DEFAULT ((0)) NOT NULL,
    [OverrideFactor6]   [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor6] DEFAULT ((0)) NOT NULL,
    [ts]                ROWVERSION   NULL,
    [OverrideFactor7]   [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor7] DEFAULT ((0)) NOT NULL,
    [OverrideFactor8]   [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor8] DEFAULT ((0)) NOT NULL,
    [OverrideFactor9]   [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor9] DEFAULT ((0)) NOT NULL,
    [OverrideFactor10]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor10] DEFAULT ((0)) NOT NULL,
    [OverrideFactor11]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor11] DEFAULT ((0)) NOT NULL,
    [OverrideFactor12]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor12] DEFAULT ((0)) NOT NULL,
    [OverrideFactor13]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor13] DEFAULT ((0)) NOT NULL,
    [OverrideFactor14]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor14] DEFAULT ((0)) NOT NULL,
    [OverrideFactor15]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor15] DEFAULT ((0)) NOT NULL,
    [OverrideFactor16]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor16] DEFAULT ((0)) NOT NULL,
    [OverrideFactor17]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor17] DEFAULT ((0)) NOT NULL,
    [OverrideFactor18]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor18] DEFAULT ((0)) NOT NULL,
    [OverrideFactor19]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor19] DEFAULT ((0)) NOT NULL,
    [OverrideFactor20]  [dbo].[pDec] CONSTRAINT [DF_tblPaEmpOverrideFactors_OverrideFactor20] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblPaEmpOverrideFactors] PRIMARY KEY CLUSTERED ([WithholdId] ASC, [TaxAuthorityDtlId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpOverrideFactors';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaEmpOverrideFactors';

