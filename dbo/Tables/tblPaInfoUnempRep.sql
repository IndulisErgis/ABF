CREATE TABLE [dbo].[tblPaInfoUnempRep] (
    [Id]                      INT        IDENTITY (1, 1) NOT NULL,
    [PaYear]                  SMALLINT   NOT NULL,
    [State]                   NCHAR (2)  NOT NULL,
    [FieldNumberOfSsn]        TINYINT    NOT NULL,
    [FieldNumberOfName]       TINYINT    NOT NULL,
    [FieldNumberOfTotalWages] TINYINT    NOT NULL,
    [FieldNumberOfExcessWage] TINYINT    NOT NULL,
    [FieldNumberOfTaxWages]   TINYINT    NOT NULL,
    [FieldNumberOfWksWorked]  TINYINT    NOT NULL,
    [FieldNumberOfHrsWorked]  TINYINT    NOT NULL,
    [SuiMonth]                TINYINT    NOT NULL,
    [PrinZeroEarnFlag]        BIT        CONSTRAINT [DF_tblPaInfoUnempRep_PrinZeroEarnFlag] DEFAULT ((0)) NOT NULL,
    [SortByFlag]              TINYINT    NOT NULL,
    [CF]                      XML        NULL,
    [ts]                      ROWVERSION NULL,
    CONSTRAINT [PK_tblPaInfoUnempRep] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaInfoUnempRep_PaYearState]
    ON [dbo].[tblPaInfoUnempRep]([PaYear] ASC, [State] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaInfoUnempRep';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaInfoUnempRep';

