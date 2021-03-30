CREATE TABLE [dbo].[tblGlAcctClass] (
    [AcctClassId] SMALLINT     NOT NULL,
    [Desc]        VARCHAR (30) NULL,
    [ts]          ROWVERSION   NULL,
    [CF]          XML          NULL,
    PRIMARY KEY CLUSTERED ([AcctClassId] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctClass';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctClass';

