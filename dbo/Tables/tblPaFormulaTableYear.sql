CREATE TABLE [dbo].[tblPaFormulaTableYear] (
    [Id]             INT            NOT NULL,
    [FormulaTableId] INT            NOT NULL,
    [PaYear]         SMALLINT       NOT NULL,
    [ColumnHdr]      NVARCHAR (255) NULL,
    [ColumnHdr1]     NVARCHAR (30)  NULL,
    [ColumnHdr2]     NVARCHAR (30)  NULL,
    [ColumnHdr3]     NVARCHAR (30)  NULL,
    [ColumnHdr4]     NVARCHAR (30)  NULL,
    [ColumnHdr5]     NVARCHAR (30)  NULL,
    [ColumnHdr6]     NVARCHAR (30)  NULL,
    [ColumnHdr7]     NVARCHAR (30)  NULL,
    [CF]             XML            NULL,
    [ts]             ROWVERSION     NULL,
    CONSTRAINT [PK_tblPaFormulaTableYear] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaFormulaTableYear_FormulaTableIdPaYear]
    ON [dbo].[tblPaFormulaTableYear]([FormulaTableId] ASC, [PaYear] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaFormulaTableYear';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaFormulaTableYear';

