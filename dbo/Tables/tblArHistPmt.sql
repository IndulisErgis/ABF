CREATE TABLE [dbo].[tblArHistPmt] (
    [Counter]         INT                 IDENTITY (1, 1) NOT NULL,
    [PostRun]         [dbo].[pPostRun]    CONSTRAINT [DF__tblArHist__PostR__6DA62884] DEFAULT (0) NULL,
    [CustId]          [dbo].[pCustID]     NULL,
    [TransId]         [dbo].[pTransID]    NULL,
    [InvcNum]         [dbo].[pInvoiceNum] NULL,
    [Rep1Id]          [dbo].[pSalesRep]   NULL,
    [Rep2Id]          [dbo].[pSalesRep]   NULL,
    [CheckNum]        [dbo].[pCheckNum]   NULL,
    [CcNum]           NVARCHAR (255)      NULL,
    [CcHolder]        VARCHAR (30)        NULL,
    [BankID]          [dbo].[pBankID]     NULL,
    [DepNum]          VARCHAR (25)        NULL,
    [DistCode]        [dbo].[pDistCode]   NULL,
    [PmtMethodId]     VARCHAR (10)        NULL,
    [CcAuth]          VARCHAR (10)        NULL,
    [GLRecvAcct]      [dbo].[pGlAcct]     NULL,
    [PmtDate]         DATETIME            CONSTRAINT [DF__tblArHist__PmtDa__6E9A4CBD] DEFAULT (getdate()) NULL,
    [DiffDisc]        [dbo].[pDec]        CONSTRAINT [DF_tblArHistPmt_DiffDisc] DEFAULT (0) NULL,
    [DiffDiscFgn]     [dbo].[pDec]        CONSTRAINT [DF_tblArHistPmt_DiffDiscFgn] DEFAULT (0) NULL,
    [PmtAmt]          [dbo].[pDec]        CONSTRAINT [DF_tblArHistPmt_PmtAmt] DEFAULT (0) NULL,
    [PmtAmtFgn]       [dbo].[pDec]        CONSTRAINT [DF_tblArHistPmt_PmtAmtFgn] DEFAULT (0) NULL,
    [PmtType]         TINYINT             CONSTRAINT [DF__tblArHist__PmtTy__735F01DA] DEFAULT (1) NULL,
    [GLPeriod]        SMALLINT            CONSTRAINT [DF__tblArHist__GLPer__74532613] DEFAULT (0) NULL,
    [FiscalYear]      SMALLINT            CONSTRAINT [DF__tblArHist__Fisca__75474A4C] DEFAULT (0) NULL,
    [CurrencyId]      [dbo].[pCurrency]   NULL,
    [ExchRate]        [dbo].[pDec]        CONSTRAINT [DF__tblArHist__ExchR__763B6E85] DEFAULT (1) NULL,
    [SumHistPeriod]   SMALLINT            CONSTRAINT [DF_tblArHistPmt_SumHistPeriod] DEFAULT (1) NULL,
    [CalcGainLoss]    [dbo].[pDec]        DEFAULT ((0)) NULL,
    [BankAcctNum]     NVARCHAR (255)      NULL,
    [BankName]        VARCHAR (30)        NULL,
    [BankRoutingCode] VARCHAR (9)         NULL,
    [RecType]         TINYINT             CONSTRAINT [DF_tblArHistPmt_RecType] DEFAULT ((0)) NOT NULL,
    [CcExpire]        DATETIME            NULL,
    [Note]            VARCHAR (25)        NULL,
    [GlAcctGainLoss]  [dbo].[pGlAcct]     NULL,
    [GlAcctDebit]     [dbo].[pGlAcct]     NULL,
    [PostDate]        DATETIME            NULL,
    [SourceId]        UNIQUEIDENTIFIER    NOT NULL,
    [CF]              XML                 NULL,
    [VoidYn]          BIT                 CONSTRAINT [DF_tblArHistPmt_VoidYn] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__tblArHistPmt__6CB2044B] PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlCustId]
    ON [dbo].[tblArHistPmt]([CustId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblArHistPmt] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArHistPmt] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblArHistPmt] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblArHistPmt] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistPmt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistPmt';

