CREATE TABLE [dbo].[ALP_tblJmSvcTktPmt] (
    [TicketId]           INT          NOT NULL,
    [BankID]             VARCHAR (10) NULL,
    [PmtAmt]             [dbo].[pDec] CONSTRAINT [DF_tblJmSvcTktPmt_PmtAmt] DEFAULT (0) NOT NULL,
    [CheckNum]           VARCHAR (10) NULL,
    [PmtMethodId]        VARCHAR (10) NULL,
    [CcHolder]           VARCHAR (30) NULL,
    [CcNum]              VARCHAR (20) NULL,
    [CcExpire]           DATETIME     NULL,
    [CcAuth]             VARCHAR (10) NULL,
    [Note]               VARCHAR (25) NULL,
    [CurrencyID]         VARCHAR (6)  NULL,
    [ts]                 ROWVERSION   NULL,
    [ModifiedBy]         VARCHAR (50) NULL,
    [ModifiedDate]       DATETIME     NULL,
    [ArCashRcptHeaderID] INT          NULL,
    [CashRcptCreated]    BIT          CONSTRAINT [DF_ALP_tblJmSvcTktPmt_CashRcptCreated] DEFAULT ((0)) NULL,
    [PmtDate]            DATETIME     CONSTRAINT [DF_ALP_tblJmSvcTktPmt_PmtDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_tblJmSvcTktPmt] PRIMARY KEY CLUSTERED ([TicketId] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblJmSvcTktPmt]
    ON [dbo].[ALP_tblJmSvcTktPmt]([TicketId] ASC) WITH (FILLFACTOR = 80);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ALP_tblJmSvcTktPmt] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ALP_tblJmSvcTktPmt] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ALP_tblJmSvcTktPmt] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ALP_tblJmSvcTktPmt] TO PUBLIC
    AS [dbo];

