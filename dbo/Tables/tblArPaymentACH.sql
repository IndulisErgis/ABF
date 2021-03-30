CREATE TABLE [dbo].[tblArPaymentACH] (
    [Counter]               INT              IDENTITY (1, 1) NOT NULL,
    [BankID]                [dbo].[pBankID]  NULL,
    [TransmitDate]          DATETIME         NULL,
    [CustID]                [dbo].[pCustID]  NULL,
    [CustomerName]          VARCHAR (30)     NULL,
    [CustomerBankName]      VARCHAR (30)     NULL,
    [CustomerRoutingCode]   VARCHAR (9)      NULL,
    [CustomerAccountNumber] NVARCHAR (255)   NULL,
    [CustomerAcctType]      TINYINT          DEFAULT ((0)) NOT NULL,
    [PaymentAmount]         [dbo].[pDec]     DEFAULT ((0)) NOT NULL,
    [PaymentDate]           DATETIME         NULL,
    [PostRun]               [dbo].[pPostRun] NULL,
    [TransID]               [dbo].[pTransID] NULL,
    [TransactionType]       TINYINT          DEFAULT ((0)) NOT NULL,
    [CF]                    XML              NULL,
    [ts]                    ROWVERSION       NULL,
    CONSTRAINT [PK_tblArPaymentACH] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArPaymentACH';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArPaymentACH';

