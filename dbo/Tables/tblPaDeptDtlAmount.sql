CREATE TABLE [dbo].[tblPaDeptDtlAmount] (
    [Id]        INT          IDENTITY (1, 1) NOT NULL,
    [DeptDtlId] INT          NOT NULL,
    [PaYear]    SMALLINT     NOT NULL,
    [PaMonth]   TINYINT      NOT NULL,
    [Amount]    [dbo].[pDec] CONSTRAINT [DF_tblPaDeptDtlAmount_Amount] DEFAULT ((0)) NOT NULL,
    [EntryDate] DATETIME     NOT NULL,
    [ts]        ROWVERSION   NULL,
    CONSTRAINT [PK_tblPaDeptDtlAmount] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPaDeptDtlAmount_PaYearPaMonthDeptDtlId]
    ON [dbo].[tblPaDeptDtlAmount]([PaYear] ASC, [PaMonth] ASC, [DeptDtlId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaDeptDtlAmount';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaDeptDtlAmount';

