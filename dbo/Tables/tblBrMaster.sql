CREATE TABLE [dbo].[tblBrMaster] (
    [EntryNum]    INT                  IDENTITY (1, 1) NOT NULL,
    [BankID]      [dbo].[pBankID]      NULL,
    [TransType]   SMALLINT             CONSTRAINT [DF__tblBrMast__Trans__35B6D51C] DEFAULT (0) NULL,
    [SourceID]    VARCHAR (10)         NULL,
    [Descr]       [dbo].[pDescription] NULL,
    [Reference]   VARCHAR (15)         NULL,
    [SourceApp]   VARCHAR (2)          NULL,
    [Amount]      [dbo].[pDec]         CONSTRAINT [DF__tblBrMast__Amoun__36AAF955] DEFAULT (0) NULL,
    [AmountFgn]   [dbo].[pDec]         CONSTRAINT [DF__tblBrMast__Amoun__379F1D8E] DEFAULT (0) NULL,
    [TransDate]   DATETIME             NULL,
    [FiscalYear]  SMALLINT             CONSTRAINT [DF__tblBrMast__Fisca__389341C7] DEFAULT (0) NULL,
    [GlPeriod]    SMALLINT             CONSTRAINT [DF__tblBrMast__GlPer__39876600] DEFAULT (0) NULL,
    [ClearedYn]   BIT                  CONSTRAINT [DF__tblBrMast__Clear__3A7B8A39] DEFAULT (0) NULL,
    [VoidTransID] [dbo].[pTransID]     NULL,
    [VoidStop]    TINYINT              CONSTRAINT [DF__tblBrMast__VoidS__3B6FAE72] DEFAULT (0) NULL,
    [CurrencyId]  [dbo].[pCurrency]    NULL,
    [ExchRate]    [dbo].[pDec]         CONSTRAINT [DF__tblBrMast__ExchR__3C63D2AB] DEFAULT (1) NULL,
    [ts]          ROWVERSION           NULL,
    [VoidAmt]     [dbo].[pDec]         DEFAULT ((0)) NULL,
    [VoidAmtFgn]  [dbo].[pDec]         DEFAULT ((0)) NULL,
    [VoidDate]    DATETIME             NULL,
    [VoidPd]      TINYINT              DEFAULT ((0)) NULL,
    [VoidYear]    SMALLINT             DEFAULT ((0)) NULL,
    [CF]          XML                  NULL,
    [ACHBatch]    BIGINT               NULL,
    [StatementID] BIGINT               NULL,
    CONSTRAINT [PK__tblBrMaster__61F08603] PRIMARY KEY CLUSTERED ([EntryNum] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE NONCLUSTERED INDEX [sqlTransDate]
    ON [dbo].[tblBrMaster]([TransDate] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [sqlSourceID]
    ON [dbo].[tblBrMaster]([SourceID] ASC) WITH (FILLFACTOR = 80);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrMaster';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrMaster';

