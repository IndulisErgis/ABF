CREATE TABLE [dbo].[tblPaCheckPosPay] (
    [Counter]         INT               IDENTITY (1, 1) NOT NULL,
    [BankID]          [dbo].[pBankID]   NOT NULL,
    [CheckNumber]     [dbo].[pCheckNum] NOT NULL,
    [AccountNumber]   [dbo].[pGlAcct]   NULL,
    [ActionType]      TINYINT           DEFAULT ((0)) NOT NULL,
    [TransactionType] TINYINT           DEFAULT ((0)) NOT NULL,
    [CheckAmount]     [dbo].[pDec]      DEFAULT ((0)) NOT NULL,
    [CheckDate]       DATETIME          NULL,
    [PayeeName]       VARCHAR (38)      NULL,
    [PayeeAddress1]   VARCHAR (30)      NULL,
    [PayeeAddress2]   VARCHAR (60)      NULL,
    [PayeeCity]       VARCHAR (30)      NULL,
    [PayeeRegion]     VARCHAR (10)      NULL,
    [PayeePostalCode] VARCHAR (10)      NULL,
    [BatchID]         [dbo].[pBatchID]  NULL,
    [PostRun]         [dbo].[pPostRun]  NULL,
    [TransmitDate]    DATETIME          NULL,
    [CF]              XML               NULL,
    [ts]              ROWVERSION        NULL,
    CONSTRAINT [PK_tblPaCheckPosPay] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_tblPaCheckPosPay]
    ON [dbo].[tblPaCheckPosPay]([BankID] ASC, [CheckNumber] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckPosPay';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPaCheckPosPay';

