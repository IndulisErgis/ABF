CREATE TABLE [dbo].[tblPaYear_Common] (
    [PaYear]     SMALLINT    CONSTRAINT [DF__tblPaYear__PaYea__58E1AC76] DEFAULT (0) NOT NULL,
    [DataPath]   VARCHAR (7) NULL,
    [CurrentYn]  BIT         CONSTRAINT [DF__tblPaYear__Curre__59D5D0AF] DEFAULT (0) NOT NULL,
    [ts]         ROWVERSION  NULL,
    [PayrollNum] SMALLINT    CONSTRAINT [DF_tblPaYear_Common_PayrollNum] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK__tblPaYear_Common__49E3F248] PRIMARY KEY CLUSTERED ([PaYear] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblPaYear_Common] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblPaYear_Common] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblPaYear_Common] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblPaYear_Common] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaYear_Common';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaYear_Common';

