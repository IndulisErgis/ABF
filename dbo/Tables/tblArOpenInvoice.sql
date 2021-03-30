CREATE TABLE [dbo].[tblArOpenInvoice] (
    [Counter]        INT                 IDENTITY (1, 1) NOT NULL,
    [CustId]         [dbo].[pCustID]     NULL,
    [InvcNum]        [dbo].[pInvoiceNum] NULL,
    [RecType]        SMALLINT            CONSTRAINT [DF__tblArOpen__RecTy__0C2AAFA4] DEFAULT (1) NULL,
    [Status]         TINYINT             CONSTRAINT [DF__tblArOpen__Statu__0D1ED3DD] DEFAULT (0) NULL,
    [DistCode]       [dbo].[pDistCode]   NULL,
    [TermsCode]      [dbo].[pTermsCode]  NULL,
    [TransDate]      DATETIME            CONSTRAINT [DF__tblArOpen__Trans__0E12F816] DEFAULT (getdate()) NULL,
    [DiscDueDate]    DATETIME            NULL,
    [NetDueDate]     DATETIME            NULL,
    [Amt]            [dbo].[pDec]        CONSTRAINT [DF_tblArOpenInvoice_Amt] DEFAULT (0) NULL,
    [AmtFgn]         [dbo].[pDec]        CONSTRAINT [DF_tblArOpenInvoice_AmtFgn] DEFAULT (0) NULL,
    [DiscAmt]        [dbo].[pDec]        CONSTRAINT [DF_tblArOpenInvoice_DiscAmt] DEFAULT (0) NULL,
    [DiscAmtFgn]     [dbo].[pDec]        CONSTRAINT [DF_tblArOpenInvoice_DiscAmtFgn] DEFAULT (0) NULL,
    [PmtMethodId]    VARCHAR (10)        NULL,
    [CheckNum]       [dbo].[pCheckNum]   NULL,
    [JobId]          VARCHAR (10)        NULL,
    [CurrencyId]     [dbo].[pCurrency]   NULL,
    [ExchRate]       [dbo].[pDec]        CONSTRAINT [DF__tblArOpen__ExchR__12D7AD33] DEFAULT (1) NULL,
    [GlPeriod]       SMALLINT            CONSTRAINT [DF__tblArOpen__GlPer__13CBD16C] DEFAULT (0) NULL,
    [FiscalYear]     SMALLINT            CONSTRAINT [DF__tblArOpen__Fisca__14BFF5A5] DEFAULT (0) NULL,
    [PhaseId]        VARCHAR (10)        NULL,
    [ProjId]         VARCHAR (10)        NULL,
    [ts]             ROWVERSION          NULL,
    [CredMemNum]     [dbo].[pInvoiceNum] NULL,
    [PostRun]        [dbo].[pPostRun]    NULL,
    [TransId]        [dbo].[pTransID]    NULL,
    [GainLossStatus] SMALLINT            DEFAULT ((0)) NULL,
    [CustPONum]      VARCHAR (25)        NULL,
    [SourceApp]      TINYINT             DEFAULT ((0)) NULL,
    [CF]             XML                 NULL,
    CONSTRAINT [PK_tblArOpenInvoice] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblArOpenInvoice_RecType_Status_TransDate]
    ON [dbo].[tblArOpenInvoice]([RecType] ASC, [Status] ASC, [TransDate] ASC)
    INCLUDE([CustId], [InvcNum], [AmtFgn]);


GO
CREATE NONCLUSTERED INDEX [IX_tblArOpenInvoice_Status]
    ON [dbo].[tblArOpenInvoice]([Status] ASC);


GO
CREATE NONCLUSTERED INDEX [sqlInvcNum]
    ON [dbo].[tblArOpenInvoice]([InvcNum] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlCustId]
    ON [dbo].[tblArOpenInvoice]([CustId] ASC);


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblArOpenInvoice] TO [WebUserRole]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArOpenInvoice';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArOpenInvoice';

