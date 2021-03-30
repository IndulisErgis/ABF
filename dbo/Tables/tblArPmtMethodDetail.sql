CREATE TABLE [dbo].[tblArPmtMethodDetail] (
    [PmtMethodID] VARCHAR (10) NOT NULL,
    [FiscalYear]  SMALLINT     CONSTRAINT [DF__tblArPmtM__Fisca__4A27E21D] DEFAULT (0) NOT NULL,
    [GLPeriod]    SMALLINT     CONSTRAINT [DF__tblArPmtM__GLPer__4B1C0656] DEFAULT (0) NOT NULL,
    [Pmt]         [dbo].[pDec] CONSTRAINT [DF_tblArPmtMethodDetail_Pmt] DEFAULT (0) NOT NULL,
    [ts]          ROWVERSION   NULL,
    [CF]          XML          NULL,
    CONSTRAINT [PK__tblArPmtMethodDe__4933BDE4] PRIMARY KEY CLUSTERED ([PmtMethodID] ASC, [FiscalYear] ASC, [GLPeriod] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArPmtMethodDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArPmtMethodDetail';

