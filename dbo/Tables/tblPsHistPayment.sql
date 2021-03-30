CREATE TABLE [dbo].[tblPsHistPayment] (
    [ID]              BIGINT            NOT NULL,
    [PostRun]         [dbo].[pPostRun]  NOT NULL,
    [HeaderID]        BIGINT            NULL,
    [PmtDate]         DATETIME          NOT NULL,
    [CustID]          [dbo].[pCustID]   NULL,
    [PmtType]         TINYINT           NOT NULL,
    [PmtMethodID]     NVARCHAR (10)     NULL,
    [CcNum]           NVARCHAR (255)    NULL,
    [CcHolder]        NVARCHAR (30)     NULL,
    [CcExpire]        DATETIME          NULL,
    [CcAuth]          NVARCHAR (10)     NULL,
    [CcRef]           NVARCHAR (255)    NULL,
    [CheckNum]        [dbo].[pCheckNum] NULL,
    [BankName]        NVARCHAR (30)     NULL,
    [BankRoutingCode] NVARCHAR (9)      NULL,
    [BankAcctNum]     NVARCHAR (255)    NULL,
    [Amount]          [dbo].[pDecimal]  NOT NULL,
    [AmountBase]      [dbo].[pDecimal]  NOT NULL,
    [CurrencyID]      [dbo].[pCurrency] NOT NULL,
    [VoidDate]        DATETIME          NULL,
    [UserID]          BIGINT            NOT NULL,
    [HostID]          [dbo].[pWrkStnID] NOT NULL,
    [EntryDate]       DATETIME          NOT NULL,
    [LocID]           [dbo].[pLocID]    NULL,
    [DistCode]        [dbo].[pDistCode] NULL,
    [GLAcctCash]      [dbo].[pGlAcct]   NULL,
    [GLAcct]          [dbo].[pGlAcct]   NULL,
    [Response]        NVARCHAR (MAX)    NULL,
    [Notes]           NVARCHAR (MAX)    NULL,
    [iCap]            VARBINARY (MAX)   NULL,
    [CF]              XML               NULL,
    CONSTRAINT [PK_tblPsHistPayment] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsHistPayment_HeaderID]
    ON [dbo].[tblPsHistPayment]([HeaderID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsHistPayment';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsHistPayment';

