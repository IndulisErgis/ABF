CREATE TABLE [dbo].[tblApTermsCode] (
    [TermsCode]        [dbo].[pTermsCode] NOT NULL,
    [Desc]             VARCHAR (15)       NULL,
    [DiscPct]          [dbo].[pDec]       CONSTRAINT [DF__tblApTerm__DiscP__1282A778] DEFAULT (0) NULL,
    [DiscDayOfMonth]   BIT                CONSTRAINT [DF__tblApTerm__DiscD__1376CBB1] DEFAULT (0) NULL,
    [DiscDays]         SMALLINT           CONSTRAINT [DF__tblApTerm__DiscD__146AEFEA] DEFAULT (0) NULL,
    [DiscMinDays]      SMALLINT           CONSTRAINT [DF__tblApTerm__DiscM__155F1423] DEFAULT (0) NULL,
    [NetDueDays]       SMALLINT           CONSTRAINT [DF__tblApTerm__NetDu__1653385C] DEFAULT (0) NULL,
    [NetDueDayOfMonth] BIT                CONSTRAINT [DF__tblApTerm__NetDu__17475C95] DEFAULT (0) NULL,
    [NetDueMinDays]    SMALLINT           CONSTRAINT [DF__tblApTerm__NetDu__183B80CE] DEFAULT (0) NULL,
    [ts]               ROWVERSION         NULL,
    [CF]               XML                NULL,
    CONSTRAINT [PK__tblApTermsCode__11D4A34F] PRIMARY KEY CLUSTERED ([TermsCode] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTermsCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTermsCode';

