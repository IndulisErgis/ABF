CREATE TABLE [dbo].[tblGlAcctDtl] (
    [AcctId]     [dbo].[pGlAcct]  NOT NULL,
    [Year]       SMALLINT         CONSTRAINT [DF__tblGlAcctD__Year__5AE859CB] DEFAULT (0) NOT NULL,
    [Period]     SMALLINT         CONSTRAINT [DF__tblGlAcct__Perio__5BDC7E04] DEFAULT (0) NOT NULL,
    [Actual]     [dbo].[pCurrDec] CONSTRAINT [DF__tblGlAcctDtl_Actual] DEFAULT ((0)) NOT NULL,
    [Budget]     [dbo].[pCurrDec] CONSTRAINT [DF__tblGlAcctDtl_Budget] DEFAULT ((0)) NOT NULL,
    [Forecast]   [dbo].[pCurrDec] CONSTRAINT [DF__tblGlAcctDtl_Forecast] DEFAULT ((0)) NOT NULL,
    [Balance]    [dbo].[pCurrDec] CONSTRAINT [DF__tblGlAcctDtl_Balance] DEFAULT ((0)) NOT NULL,
    [ts]         ROWVERSION       NULL,
    [ActualBase] [dbo].[pCurrDec] CONSTRAINT [DF__tblGlAcct__ActualBase] DEFAULT ((0)) NOT NULL,
    [CF]         XML              NULL,
    CONSTRAINT [PK__tblGlAcctDtl__703EA55A] PRIMARY KEY CLUSTERED ([AcctId] ASC, [Year] ASC, [Period] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlAcctDtl';

