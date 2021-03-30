CREATE TABLE [dbo].[tblBrJrnlDetail] (
    [EntryNum]     INT                  IDENTITY (1, 1) NOT NULL,
    [TransID]      [dbo].[pTransID]     NULL,
    [GLAcct]       [dbo].[pGlAcct]      NULL,
    [DebitAmt]     [dbo].[pDec]         CONSTRAINT [DF__tblBrJrnl__Debit__22A400A8] DEFAULT (0) NULL,
    [DebitAmtFgn]  [dbo].[pDec]         CONSTRAINT [DF__tblBrJrnl__Debit__239824E1] DEFAULT (0) NULL,
    [CreditAmt]    [dbo].[pDec]         CONSTRAINT [DF__tblBrJrnl__Credi__248C491A] DEFAULT (0) NULL,
    [CreditAmtFgn] [dbo].[pDec]         CONSTRAINT [DF__tblBrJrnl__Credi__25806D53] DEFAULT (0) NULL,
    [Descr]        [dbo].[pDescription] NULL,
    [Reference]    VARCHAR (15)         NULL,
    [BankIDXferTo] [dbo].[pBankID]      NULL,
    [ExchRate]     [dbo].[pDec]         CONSTRAINT [DF__tblBrJrnl__ExchR__2674918C] DEFAULT (1) NULL,
    [ts]           ROWVERSION           NULL,
    [CF]           XML                  NULL,
    CONSTRAINT [PK__tblBrJrnlDetail__5F141958] PRIMARY KEY CLUSTERED ([EntryNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrJrnlDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrJrnlDetail';

