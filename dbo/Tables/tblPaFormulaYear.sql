CREATE TABLE [dbo].[tblPaFormulaYear] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [FormulaId]        NVARCHAR (12)  NOT NULL,
    [PaYear]           SMALLINT       NOT NULL,
    [TableId]          NVARCHAR (8)   NULL,
    [OverrideFactor1]  [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor1] DEFAULT ((0)) NOT NULL,
    [OverrideFactor2]  [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor2] DEFAULT ((0)) NOT NULL,
    [OverrideFactor3]  [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor3] DEFAULT ((0)) NOT NULL,
    [OverrideFactor4]  [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor4] DEFAULT ((0)) NOT NULL,
    [OverrideFactor5]  [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor5] DEFAULT ((0)) NOT NULL,
    [OverrideFactor6]  [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor6] DEFAULT ((0)) NOT NULL,
    [FormulaText]      NVARCHAR (MAX) NULL,
    [CF]               XML            NULL,
    [ts]               ROWVERSION     NULL,
    [OverrideFactor7]  [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor7] DEFAULT ((0)) NOT NULL,
    [OverrideFactor8]  [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor8] DEFAULT ((0)) NOT NULL,
    [OverrideFactor9]  [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor9] DEFAULT ((0)) NOT NULL,
    [OverrideFactor10] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor10] DEFAULT ((0)) NOT NULL,
    [OverrideFactor11] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor11] DEFAULT ((0)) NOT NULL,
    [OverrideFactor12] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor12] DEFAULT ((0)) NOT NULL,
    [OverrideFactor13] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor13] DEFAULT ((0)) NOT NULL,
    [OverrideFactor14] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor14] DEFAULT ((0)) NOT NULL,
    [OverrideFactor15] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor15] DEFAULT ((0)) NOT NULL,
    [OverrideFactor16] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor16] DEFAULT ((0)) NOT NULL,
    [OverrideFactor17] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor17] DEFAULT ((0)) NOT NULL,
    [OverrideFactor18] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor18] DEFAULT ((0)) NOT NULL,
    [OverrideFactor19] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor19] DEFAULT ((0)) NOT NULL,
    [OverrideFactor20] [dbo].[pDec]   CONSTRAINT [DF_tblPaFormulaYear_OverrideFactor20] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblPaFormulaYear] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaFormulaYear_TableId]
    ON [dbo].[tblPaFormulaYear]([TableId] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaFormulaYear_FormulaIdPaYear]
    ON [dbo].[tblPaFormulaYear]([FormulaId] ASC, [PaYear] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaFormulaYear';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaFormulaYear';

