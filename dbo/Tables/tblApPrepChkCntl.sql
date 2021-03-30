CREATE TABLE [dbo].[tblApPrepChkCntl] (
    [Counter]               INT               IDENTITY (1, 1) NOT NULL,
    [VendorIDFrom]          [dbo].[pVendorID] NULL,
    [VendorIDThru]          [dbo].[pVendorID] NULL,
    [Currency]              [dbo].[pCurrency] NULL,
    [InvoicesDue]           DATETIME          NULL,
    [DiscountsDue]          DATETIME          NULL,
    [CheckDate]             DATETIME          NULL,
    [GLPeriod]              SMALLINT          CONSTRAINT [DF__tblApPrep__GLPer__2E5FCC17] DEFAULT (0) NULL,
    [FiscalYear]            SMALLINT          CONSTRAINT [DF__tblApPrep__Fisca__2F53F050] DEFAULT (0) NULL,
    [PrepaidCheckTotal]     [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__Prepa__30481489] DEFAULT (0) NULL,
    [DiscountTakenTotal]    [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__Disco__313C38C2] DEFAULT (0) NULL,
    [CheckAmountTotal]      [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__Check__32305CFB] DEFAULT (0) NULL,
    [PrepaidCheckTotalFgn]  [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__Prepa__33248134] DEFAULT (0) NULL,
    [DiscountTakenTotalFgn] [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__Disco__3418A56D] DEFAULT (0) NULL,
    [CheckAmountTotalFgn]   [dbo].[pDec]      CONSTRAINT [DF__tblApPrep__Check__350CC9A6] DEFAULT (0) NULL,
    [User]                  [dbo].[pUserID]   NULL,
    [ts]                    ROWVERSION        NULL,
    [BankID]                [dbo].[pBankID]   NULL,
    [PmtCurrencyId]         [dbo].[pCurrency] NULL,
    [PmtExchRate]           [dbo].[pDec]      DEFAULT ((1)) NOT NULL,
    [BatchID]               [dbo].[pBatchID]  DEFAULT ('######') NOT NULL,
    [TransmitDate]          DATETIME          NULL,
    [ACHBatch]              INT               NULL,
    CONSTRAINT [PK__tblApPrepChkCntl__075714DC] PRIMARY KEY CLUSTERED ([Counter] ASC) WITH (FILLFACTOR = 80)
);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[tblApPrepChkCntl] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[tblApPrepChkCntl] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[tblApPrepChkCntl] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[tblApPrepChkCntl] TO PUBLIC
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApPrepChkCntl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApPrepChkCntl';

