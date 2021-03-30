CREATE TABLE [dbo].[tblArTermsCode] (
    [TermsCode]        [dbo].[pTermsCode] NOT NULL,
    [Desc]             VARCHAR (15)       NULL,
    [DiscPct]          [dbo].[pDec]       CONSTRAINT [DF_tblArTermsCode_DiscPct] DEFAULT (0) NULL,
    [DiscDayOfMonth]   BIT                CONSTRAINT [DF__tblArTerm__DiscD__29860861] DEFAULT (0) NULL,
    [DiscDays]         SMALLINT           CONSTRAINT [DF__tblArTerm__DiscD__2A7A2C9A] DEFAULT (0) NULL,
    [DiscMinDays]      SMALLINT           CONSTRAINT [DF__tblArTerm__DiscM__2B6E50D3] DEFAULT (0) NULL,
    [NetDueDays]       SMALLINT           CONSTRAINT [DF__tblArTerm__NetDu__2C62750C] DEFAULT (0) NULL,
    [NetDueDayOfMonth] BIT                CONSTRAINT [DF__tblArTerm__NetDu__2D569945] DEFAULT (0) NULL,
    [NetDueMinDays]    SMALLINT           CONSTRAINT [DF__tblArTerm__NetDu__2E4ABD7E] DEFAULT (0) NULL,
    [ts]               ROWVERSION         NULL,
    [CF]               XML                NULL,
    CONSTRAINT [PK__tblArTermsCode__279DBFEF] PRIMARY KEY CLUSTERED ([TermsCode] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArTermsCode] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArTermsCode';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArTermsCode';

