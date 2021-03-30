CREATE TABLE [dbo].[tblArHistFinch] (
    [PostRun]           [dbo].[pPostRun]  CONSTRAINT [DF__tblArHist__PostR__2437435F] DEFAULT (0) NOT NULL,
    [CustID]            [dbo].[pCustID]   NOT NULL,
    [FinchDate]         DATETIME          NULL,
    [FinchAmt]          [dbo].[pDec]      CONSTRAINT [DF_tblArHistFinch_FinchAmt] DEFAULT (0) NULL,
    [GLPeriod]          SMALLINT          CONSTRAINT [DF__tblArHist__GLPer__261F8BD1] DEFAULT (0) NULL,
    [FiscalYear]        SMALLINT          CONSTRAINT [DF__tblArHist__Fisca__2713B00A] DEFAULT (0) NULL,
    [SumHistPeriod]     SMALLINT          CONSTRAINT [DF_tblArHistFinch_SumHistPeriod] DEFAULT (1) NULL,
    [CurrencyID]        [dbo].[pCurrency] NULL,
    [FinchAmtFgn]       [dbo].[pDec]      CONSTRAINT [DF_tblArHistFinch_FinchAmtFgn] DEFAULT ((0)) NULL,
    [ExchRate]          [dbo].[pDec]      CONSTRAINT [DF__tblArHistFinch__ExchRate] DEFAULT ((1)) NULL,
    [CF]                XML               NULL,
    [GLAcctFinch]       [dbo].[pGlAcct]   NULL,
    [GLAcctReceivables] [dbo].[pGlAcct]   NULL,
    CONSTRAINT [PK__tblArHistFinch__23431F26] PRIMARY KEY CLUSTERED ([PostRun] ASC, [CustID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblArHistFinch_FiscalYear_GlPeriod]
    ON [dbo].[tblArHistFinch]([FiscalYear] ASC, [GLPeriod] ASC)
    INCLUDE([FinchAmtFgn]);


GO
CREATE NONCLUSTERED INDEX [sqlCustID]
    ON [dbo].[tblArHistFinch]([CustID] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblArHistFinch] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArHistFinch] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblArHistFinch] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblArHistFinch] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistFinch';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistFinch';

