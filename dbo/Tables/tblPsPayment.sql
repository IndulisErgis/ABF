CREATE TABLE [dbo].[tblPsPayment] (
    [ID]              BIGINT            NOT NULL,
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
    [PostedYN]        BIT               CONSTRAINT [DF_tblPsPayment_PostedYN] DEFAULT ((0)) NOT NULL,
    [VoidDate]        DATETIME          NULL,
    [UserID]          BIGINT            NOT NULL,
    [HostID]          [dbo].[pWrkStnID] NOT NULL,
    [EntryDate]       DATETIME          NOT NULL,
    [Synched]         BIT               NOT NULL,
    [Settled]         BIT               NOT NULL,
    [Response]        NVARCHAR (MAX)    NULL,
    [Notes]           NVARCHAR (MAX)    NULL,
    [iCap]            VARBINARY (MAX)   NULL,
    [CF]              XML               NULL,
    [ts]              ROWVERSION        NULL,
    [SynchID]         BIGINT            NULL,
    [ConfigID]        BIGINT            NOT NULL,
    CONSTRAINT [PK_tblPsPayment] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsPayment_HostID]
    ON [dbo].[tblPsPayment]([HostID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsPayment_ConfigID]
    ON [dbo].[tblPsPayment]([ConfigID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsPayment_SynchID]
    ON [dbo].[tblPsPayment]([SynchID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblPsPayment_TransID]
    ON [dbo].[tblPsPayment]([HeaderID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsPayment';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPsPayment';

