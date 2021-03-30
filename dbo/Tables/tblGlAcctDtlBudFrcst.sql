CREATE TABLE [dbo].[tblGlAcctDtlBudFrcst] (
    [BFAcctDtlRef] INT             IDENTITY (1, 1) NOT NULL,
    [AcctID]       [dbo].[pGlAcct] NOT NULL,
    [BFRef]        INT             NOT NULL,
    [GlPeriod]     SMALLINT        NOT NULL,
    [GlYear]       SMALLINT        NOT NULL,
    [Amount]       [dbo].[pDec]    DEFAULT ((0)) NULL,
    [ts]           ROWVERSION      NULL,
    [CF]           XML             NULL,
    CONSTRAINT [PK_tblGlAcctDtlBudFrcst] PRIMARY KEY NONCLUSTERED ([BFAcctDtlRef] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UI_tblGlAcctDtlBudFrcst_AcctIdBFRefGlPeriodGlYear]
    ON [dbo].[tblGlAcctDtlBudFrcst]([AcctID] ASC, [BFRef] ASC, [GlPeriod] ASC, [GlYear] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctDtlBudFrcst';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctDtlBudFrcst';

