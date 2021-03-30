CREATE TABLE [dbo].[tblArCashRcptHeader] (
    [RcptHeaderID]     INT               IDENTITY (1, 1) NOT NULL,
    [DepositID]        [dbo].[pBatchID]  CONSTRAINT [DF__tblArCash__Depos__41FCB070] DEFAULT ('######') NULL,
    [BankID]           [dbo].[pBankID]   NULL,
    [PmtDate]          DATETIME          CONSTRAINT [DF__tblArCash__PmtDa__42F0D4A9] DEFAULT (getdate()) NULL,
    [PmtAmt]           [dbo].[pDec]      NULL,
    [AgingPd]          SMALLINT          CONSTRAINT [DF__tblArCash__Aging__44D91D1B] DEFAULT (0) NULL,
    [CheckNum]         [dbo].[pCheckNum] NULL,
    [CustId]           [dbo].[pCustID]   NULL,
    [GLAcct]           [dbo].[pGlAcct]   NULL,
    [GLPeriod]         SMALLINT          CONSTRAINT [DF__tblArCash__GLPer__45CD4154] DEFAULT (1) NULL,
    [FiscalYear]       SMALLINT          CONSTRAINT [DF__tblArCash__Fisca__46C1658D] DEFAULT (0) NULL,
    [PmtMethodId]      VARCHAR (10)      NULL,
    [CcHolder]         VARCHAR (30)      NULL,
    [CcNum]            NVARCHAR (255)    NULL,
    [CcExpire]         DATETIME          NULL,
    [CcAuth]           VARCHAR (10)      NULL,
    [Note]             VARCHAR (25)      NULL,
    [CurrencyID]       [dbo].[pCurrency] NOT NULL,
    [ExchRate]         [dbo].[pDec]      CONSTRAINT [DF__tblArCash__ExchR__47B589C6] DEFAULT (1) NULL,
    [InvcTransID]      [dbo].[pTransID]  NULL,
    [InvcAppID]        VARCHAR (2)       NULL,
    [SumHistPeriod]    SMALLINT          CONSTRAINT [DF__tblArCash__SumHi__48A9ADFF] DEFAULT (0) NULL,
    [ts]               ROWVERSION        NULL,
    [BankAcctNum]      NVARCHAR (255)    NULL,
    [BankName]         VARCHAR (30)      NULL,
    [BankRoutingCode]  VARCHAR (9)       NULL,
    [CcSecCode]        VARCHAR (6)       NULL,
    [CF]               XML               NULL,
    [SourceId]         UNIQUEIDENTIFIER  NOT NULL,
    [OrderState]       TINYINT           CONSTRAINT [DF_tblArCashRcptHeader_OrderState] DEFAULT ((0)) NOT NULL,
    [ExtPmtActivityID] BIGINT            NULL,
    CONSTRAINT [PK__tblArCashRcptHea__41088C37] PRIMARY KEY CLUSTERED ([RcptHeaderID] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlDepositID]
    ON [dbo].[tblArCashRcptHeader]([DepositID] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArCashRcptHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArCashRcptHeader';

