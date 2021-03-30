CREATE TABLE [dbo].[tblSmExternalPaymentActivity] (
    [ID]                   BIGINT            NOT NULL,
    [ParentID]             BIGINT            NULL,
    [ActType]              TINYINT           NOT NULL,
    [ActStatus]            TINYINT           NOT NULL,
    [SourceStatus]         TINYINT           NOT NULL,
    [EntryDate]            DATETIME          CONSTRAINT [DF_tblSmExternalPaymentActivity_EntryDate] DEFAULT (getdate()) NOT NULL,
    [TransDate]            DATETIME          NOT NULL,
    [PmtMethodID]          NVARCHAR (10)     NULL,
    [ExtPmtMethodID]       BIGINT            NULL,
    [CustomerID]           [dbo].[pCustID]   NULL,
    [CustomerReference]    NVARCHAR (255)    NULL,
    [FiscalYear]           SMALLINT          NULL,
    [FiscalPeriod]         SMALLINT          NULL,
    [SourceID]             UNIQUEIDENTIFIER  NULL,
    [SourceType]           TINYINT           CONSTRAINT [DF_tblSmExternalPaymentActivity_SourceType] DEFAULT ((1)) NOT NULL,
    [SourceDocument]       NVARCHAR (255)    NULL,
    [SourceReference]      NVARCHAR (255)    NULL,
    [CustomerPaymentAlias] NVARCHAR (255)    NULL,
    [ServiceID]            INT               NOT NULL,
    [AuthorizationCode]    NVARCHAR (255)    NOT NULL,
    [TransactionID]        NVARCHAR (255)    NOT NULL,
    [PaymentDate]          DATETIME          NULL,
    [PaymentAmount]        [dbo].[pDecimal]  CONSTRAINT [DF_tblSmExternalPaymentActivity_PaymentAmount] DEFAULT ((0)) NOT NULL,
    [CurrencyId]           [dbo].[pCurrency] NOT NULL,
    [ProcessLevel]         TINYINT           CONSTRAINT [DF_tblSmExternalPaymentActivity_ProcessLevel] DEFAULT ((0)) NOT NULL,
    [ResponseCode]         NVARCHAR (10)     NULL,
    [ResponseMessage]      NVARCHAR (MAX)    NULL,
    [Response]             NVARCHAR (MAX)    NULL,
    [WebPostData]          NVARCHAR (MAX)    NULL,
    [RequestData]          NVARCHAR (MAX)    NULL,
    [CF]                   XML               NULL,
    [ts]                   ROWVERSION        NULL,
    CONSTRAINT [PK_tblSmExternalPaymentActivity] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblSmExternalPaymentActivity_ParentID]
    ON [dbo].[tblSmExternalPaymentActivity]([ParentID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmExternalPaymentActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmExternalPaymentActivity';

