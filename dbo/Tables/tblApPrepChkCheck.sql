CREATE TABLE [dbo].[tblApPrepChkCheck] (
    [Counter]         INT               IDENTITY (1, 1) NOT NULL,
    [VendorID]        [dbo].[pVendorID] NULL,
    [CheckNum]        [dbo].[pCheckNum] NULL,
    [CheckAmt]        [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__Check__2105D0F9] DEFAULT (0) NULL,
    [DiscTaken]       [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__DiscT__21F9F532] DEFAULT (0) NULL,
    [DiscLost]        [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__DiscL__22EE196B] DEFAULT (0) NULL,
    [Ten99Pmt]        [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__Ten99__23E23DA4] DEFAULT (0) NULL,
    [CheckAmtFgn]     [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__Check__24D661DD] DEFAULT (0) NULL,
    [DiscTakenFgn]    [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__DiscT__25CA8616] DEFAULT (0) NULL,
    [DiscLostFgn]     [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__DiscL__26BEAA4F] DEFAULT (0) NULL,
    [Ten99PmtFgn]     [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__Ten99__27B2CE88] DEFAULT (0) NULL,
    [CheckDate]       DATETIME          NULL,
    [GLCashAcct]      [dbo].[pGlAcct]   NULL,
    [CurrencyId]      [dbo].[pCurrency] NULL,
    [ts]              ROWVERSION        NULL,
    [CalcGainLoss]    [dbo].[pDec]      DEFAULT ((0)) NOT NULL,
    [GLAccGainLoss]   [dbo].[pGlAcct]   NULL,
    [BatchID]         [dbo].[pBatchID]  DEFAULT ('######') NOT NULL,
    [GrpID]           INT               DEFAULT ((0)) NOT NULL,
    [DeliveryType]    TINYINT           DEFAULT ((0)) NULL,
    [BankAcctNum]     NVARCHAR (255)    NULL,
    [RoutingCode]     VARCHAR (9)       NULL,
    [BankAccountType] TINYINT           CONSTRAINT [DF_tblApPrepChkCheck_BankAccountType] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__tblApPrepChkChec__0662F0A3] PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlVendorID]
    ON [dbo].[tblApPrepChkCheck]([VendorID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlCheckNum]
    ON [dbo].[tblApPrepChkCheck]([CheckNum] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApPrepChkCheck';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApPrepChkCheck';

