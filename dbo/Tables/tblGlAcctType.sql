CREATE TABLE [dbo].[tblGlAcctType] (
    [AcctTypeId]  SMALLINT     CONSTRAINT [DF__tblGlAcct__AcctT__7A610524] DEFAULT (0) NOT NULL,
    [Desc]        VARCHAR (30) NULL,
    [AcctClassId] SMALLINT     CONSTRAINT [DF__tblGlAcct__AcctC__7B55295D] DEFAULT (0) NOT NULL,
    [AcctCode]    SMALLINT     CONSTRAINT [DF__tblGlAcct__AcctC__7C494D96] DEFAULT (0) NULL,
    [ts]          ROWVERSION   NULL,
    [CF]          XML          NULL,
    PRIMARY KEY CLUSTERED ([AcctTypeId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlAcctClassId]
    ON [dbo].[tblGlAcctType]([AcctClassId] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctType';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctType';

