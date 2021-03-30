CREATE TABLE [dbo].[tblPaFormulaTableHeader] (
    [Id]          INT           NOT NULL,
    [TableId]     NVARCHAR (8)  NOT NULL,
    [Status]      NVARCHAR (3)  NOT NULL,
    [Description] NVARCHAR (40) NULL,
    [CF]          XML           NULL,
    [ts]          ROWVERSION    NULL,
    CONSTRAINT [PK_tblPaFormulaTableHeader] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaFormulaTableHeader_TableIdStatus]
    ON [dbo].[tblPaFormulaTableHeader]([TableId] ASC, [Status] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaFormulaTableHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaFormulaTableHeader';

