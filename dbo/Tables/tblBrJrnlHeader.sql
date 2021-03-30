CREATE TABLE [dbo].[tblBrJrnlHeader] (
    [TransID]           [dbo].[pTransID]     NOT NULL,
    [BankID]            [dbo].[pBankID]      NULL,
    [TransType]         SMALLINT             CONSTRAINT [DF__tblBrJrnl__Trans__2950FE37] DEFAULT (0) NULL,
    [SourceID]          VARCHAR (10)         NULL,
    [Descr]             [dbo].[pDescription] NULL,
    [TransDate]         DATETIME             NULL,
    [GLPeriod]          SMALLINT             CONSTRAINT [DF__tblBrJrnl__GLPer__2A452270] DEFAULT (1) NULL,
    [FiscalYear]        SMALLINT             CONSTRAINT [DF__tblBrJrnl__Fisca__2B3946A9] DEFAULT (0) NULL,
    [Reference]         VARCHAR (15)         NULL,
    [Amount]            [dbo].[pDec]         CONSTRAINT [DF__tblBrJrnl__Amoun__2C2D6AE2] DEFAULT (0) NULL,
    [AmountFgn]         [dbo].[pDec]         CONSTRAINT [DF__tblBrJrnl__Amoun__2D218F1B] DEFAULT (0) NULL,
    [CurrencyId]        [dbo].[pCurrency]    NULL,
    [ExchRate]          [dbo].[pDec]         CONSTRAINT [DF__tblBrJrnl__ExchR__2E15B354] DEFAULT (1) NULL,
    [VoidYn]            BIT                  CONSTRAINT [DF__tblBrJrnl__VoidY__2F09D78D] DEFAULT (0) NULL,
    [VoidReinstateStat] TINYINT              NULL,
    [Ten99Yr]           TINYINT              CONSTRAINT [DF__tblBrJrnl__Ten99__2FFDFBC6] DEFAULT (1) NULL,
    [ts]                ROWVERSION           NULL,
    [CreateTransaction] BIT                  CONSTRAINT [DF_tblBrJrnlHeader_CreateTransaction] DEFAULT ((1)) NOT NULL,
    [CreateManualCheck] BIT                  CONSTRAINT [DF_tblBrJrnlHeader_CreateManualCheck] DEFAULT ((1)) NOT NULL,
    [PayrollMonth]      SMALLINT             NULL,
    [CF]                XML                  NULL,
    CONSTRAINT [PK__tblBrJrnlHeader__60083D91] PRIMARY KEY CLUSTERED ([TransID] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrJrnlHeader';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrJrnlHeader';

