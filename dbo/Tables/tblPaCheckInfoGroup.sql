CREATE TABLE [dbo].[tblPaCheckInfoGroup] (
    [InfoId]          INT        NOT NULL,
    [Id]              INT        NOT NULL,
    [Selected]        BIT        CONSTRAINT [DF_tblPaCheckInfoGroup_Selected] DEFAULT ((0)) NOT NULL,
    [PeriodStartDate] DATETIME   NULL,
    [PdCode]          TINYINT    CONSTRAINT [DF_tblPaCheckInfoGroup_PdCode] DEFAULT ((1)) NOT NULL,
    [ts]              ROWVERSION NULL,
    CONSTRAINT [PK_tblPaCheckInfoGroup] PRIMARY KEY CLUSTERED ([InfoId] ASC, [Id] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckInfoGroup';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckInfoGroup';

