CREATE TABLE [dbo].[tblPaFormulaHeader] (
    [Id]          NVARCHAR (12) NOT NULL,
    [Description] NVARCHAR (35) NULL,
    [CF]          XML           NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaFormulaHeader] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaFormulaHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaFormulaHeader';

