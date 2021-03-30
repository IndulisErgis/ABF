CREATE TABLE [dbo].[tblSoTransPmt] (
    [PmtNum]            INT               IDENTITY (1, 1) NOT NULL,
    [PmtDate]           DATETIME          DEFAULT (getdate()) NULL,
    [TransId]           [dbo].[pTransID]  NOT NULL,
    [DepositId]         [dbo].[pBatchID]  NOT NULL,
    [LinkId]            INT               NOT NULL,
    [PmtMethodId]       VARCHAR (10)      NOT NULL,
    [CcNum]             NVARCHAR (255)    NULL,
    [CcHolder]          VARCHAR (30)      NULL,
    [CcExpire]          DATETIME          NULL,
    [CcAuth]            VARCHAR (10)      NULL,
    [CheckNum]          [dbo].[pCheckNum] NULL,
    [Note]              VARCHAR (25)      NULL,
    [PmtAmt]            [dbo].[pDec]      DEFAULT ((0)) NULL,
    [PmtAmtFgn]         [dbo].[pDec]      DEFAULT ((0)) NULL,
    [CurrencyId]        [dbo].[pCurrency] NOT NULL,
    [ExchRate]          [dbo].[pDec]      DEFAULT ((1)) NULL,
    [CalcGainLoss]      [dbo].[pDec]      DEFAULT ((0)) NULL,
    [PostedYn]          BIT               DEFAULT ((0)) NULL,
    [CcSecCode]         VARCHAR (6)       NULL,
    [BankName]          VARCHAR (30)      NULL,
    [BankRoutingCode]   VARCHAR (9)       NULL,
    [BankAcctNum]       NVARCHAR (255)    NULL,
    [GlPeriod]          SMALLINT          DEFAULT ((1)) NOT NULL,
    [FiscalYear]        SMALLINT          DEFAULT ((0)) NOT NULL,
    [GlAcctReceivables] [dbo].[pGlAcct]   NULL,
    [GlAcctGainLoss]    [dbo].[pGlAcct]   NULL,
    [CF]                XML               NULL,
    [ts]                ROWVERSION        NULL,
    [ExtPmtActivityID]  BIGINT            NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransPmt';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSoTransPmt';

