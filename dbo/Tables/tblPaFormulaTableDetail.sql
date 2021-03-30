CREATE TABLE [dbo].[tblPaFormulaTableDetail] (
    [FormulaTableYearId] INT          NOT NULL,
    [SequenceNumber]     SMALLINT     NOT NULL,
    [Column1]            [dbo].[pDec] CONSTRAINT [DF_tblPaFormulaTableDetail_Column1] DEFAULT ((0)) NOT NULL,
    [Column2]            [dbo].[pDec] CONSTRAINT [DF_tblPaFormulaTableDetail_Column2] DEFAULT ((0)) NOT NULL,
    [Column3]            [dbo].[pDec] CONSTRAINT [DF_tblPaFormulaTableDetail_Column3] DEFAULT ((0)) NOT NULL,
    [Column4]            [dbo].[pDec] CONSTRAINT [DF_tblPaFormulaTableDetail_Column4] DEFAULT ((0)) NOT NULL,
    [Column5]            [dbo].[pDec] CONSTRAINT [DF_tblPaFormulaTableDetail_Column5] DEFAULT ((0)) NOT NULL,
    [Column6]            [dbo].[pDec] CONSTRAINT [DF_tblPaFormulaTableDetail_Column6] DEFAULT ((0)) NOT NULL,
    [Column7]            [dbo].[pDec] CONSTRAINT [DF_tblPaFormulaTableDetail_Column7] DEFAULT ((0)) NOT NULL,
    [Column8]            [dbo].[pDec] CONSTRAINT [DF_tblPaFormulaTableDetail_Column8] DEFAULT ((0)) NOT NULL,
    [Column9]            [dbo].[pDec] CONSTRAINT [DF_tblPaFormulaTableDetail_Column9] DEFAULT ((0)) NOT NULL,
    [Column10]           [dbo].[pDec] CONSTRAINT [DF_tblPaFormulaTableDetail_Column10] DEFAULT ((0)) NOT NULL,
    [GradientYn]         BIT          CONSTRAINT [DF_tblPaFormulaTableDetail_GradientYn] DEFAULT ((1)) NOT NULL,
    [CF]                 XML          NULL,
    [ts]                 ROWVERSION   NULL,
    CONSTRAINT [PK_tblPaFormulaTableDetail] PRIMARY KEY CLUSTERED ([FormulaTableYearId] ASC, [SequenceNumber] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaFormulaTableDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaFormulaTableDetail';

