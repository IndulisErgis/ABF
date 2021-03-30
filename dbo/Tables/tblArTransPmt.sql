CREATE TABLE [dbo].[tblArTransPmt] (
    [PmtNum]            INT               IDENTITY (1, 1) NOT NULL,
    [TransId]           [dbo].[pTransID]  NOT NULL,
    [DepositId]         [dbo].[pBatchID]  NOT NULL,
    [LinkId]            INT               NOT NULL,
    [PmtMethodId]       VARCHAR (10)      NOT NULL,
    [PmtDate]           DATETIME          CONSTRAINT [DF_tblArTransPmt_PmtDate] DEFAULT (getdate()) NULL,
    [PmtAmt]            [dbo].[pDec]      CONSTRAINT [DF_tblArTransPmt_PmtAmt] DEFAULT ((0)) NULL,
    [PmtAmtFgn]         [dbo].[pDec]      CONSTRAINT [DF_tblArTransPmt_PmtAmtFgn] DEFAULT ((0)) NULL,
    [CurrencyId]        [dbo].[pCurrency] NOT NULL,
    [ExchRate]          [dbo].[pDec]      CONSTRAINT [DF_tblArTransPmt_ExchRate] DEFAULT ((1)) NULL,
    [CalcGainLoss]      [dbo].[pDec]      CONSTRAINT [DF_tblArTransPmt_CalcGainLoss] DEFAULT ((0)) NULL,
    [GlAcctGainLoss]    [dbo].[pGlAcct]   NULL,
    [GlAcctReceivables] [dbo].[pGlAcct]   NULL,
    [GlPeriod]          SMALLINT          CONSTRAINT [DF_tblArTransPmt_GlPeriod] DEFAULT ((1)) NOT NULL,
    [FiscalYear]        SMALLINT          CONSTRAINT [DF_tblArTransPmt_FiscalYear] DEFAULT ((0)) NOT NULL,
    [CheckNum]          [dbo].[pCheckNum] NULL,
    [CcNum]             NVARCHAR (255)    NULL,
    [CcHolder]          VARCHAR (30)      NULL,
    [CcExpire]          DATETIME          NULL,
    [CcAuth]            VARCHAR (10)      NULL,
    [CcSecCode]         VARCHAR (6)       NULL,
    [BankName]          VARCHAR (30)      NULL,
    [BankRoutingCode]   VARCHAR (9)       NULL,
    [BankAcctNum]       NVARCHAR (255)    NULL,
    [Note]              VARCHAR (25)      NULL,
    [PostedYn]          BIT               CONSTRAINT [DF_tblArTransPmt_PostedYn] DEFAULT ((0)) NULL,
    [CF]                XML               NULL,
    [ts]                ROWVERSION        NULL,
    [ExtPmtActivityID]  BIGINT            NULL,
    CONSTRAINT [PK_tblArTransPmt] PRIMARY KEY CLUSTERED ([PmtNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [sqlTransId]
    ON [dbo].[tblArTransPmt]([TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArTransPmt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArTransPmt';

