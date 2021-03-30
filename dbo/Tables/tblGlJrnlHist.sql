CREATE TABLE [dbo].[tblGlJrnlHist] (
    [Counter]       INT               IDENTITY (1, 1) NOT NULL,
    [EntryNum]      INT               NULL,
    [CompId]        VARCHAR (3)       NULL,
    [EntryDate]     DATETIME          DEFAULT (getdate()) NULL,
    [TransDate]     DATETIME          DEFAULT (getdate()) NULL,
    [PostedYn]      SMALLINT          DEFAULT ((1)) NULL,
    [Desc]          VARCHAR (30)      NULL,
    [SourceCode]    VARCHAR (2)       DEFAULT ('M1') NULL,
    [Reference]     VARCHAR (15)      NULL,
    [AcctId]        [dbo].[pGlAcct]   NULL,
    [DebitAmt]      [dbo].[pCurrDec]  DEFAULT ((0)) NULL,
    [CreditAmt]     [dbo].[pCurrDec]  DEFAULT ((0)) NULL,
    [Period]        SMALLINT          DEFAULT ((0)) NULL,
    [Year]          SMALLINT          DEFAULT ((0)) NULL,
    [AllocateYn]    BIT               DEFAULT ((1)) NULL,
    [ChkRecon]      BIT               DEFAULT ((0)) NULL,
    [CashFlow]      BIT               DEFAULT ((0)) NULL,
    [LinkID]        NVARCHAR (255)    NULL,
    [LinkIDSub]     VARCHAR (15)      NULL,
    [LinkIDSubLine] INT               DEFAULT ((0)) NULL,
    [PostRun]       [dbo].[pPostRun]  DEFAULT ((0)) NULL,
    [ExchRate]      [dbo].[pDec]      DEFAULT ((1)) NOT NULL,
    [CurrencyID]    [dbo].[pCurrency] NULL,
    [DebitAmtFgn]   [dbo].[pCurrDec]  DEFAULT ((0)) NOT NULL,
    [CreditAmtFgn]  [dbo].[pCurrDec]  DEFAULT ((0)) NOT NULL,
    [URG]           BIT               DEFAULT ((0)) NOT NULL,
    [CF]            XML               NULL,
    [ts]            ROWVERSION        NULL
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlJrnlHist';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblGlJrnlHist';

