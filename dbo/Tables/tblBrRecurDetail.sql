CREATE TABLE [dbo].[tblBrRecurDetail] (
    [EntryNum]     INT                  IDENTITY (1, 1) NOT NULL,
    [TransID]      [dbo].[pTransID]     NULL,
    [GLAcct]       [dbo].[pGlAcct]      NULL,
    [DebitAmt]     [dbo].[pDec]         CONSTRAINT [DF__tblBrRecu__Debit__4404F473] DEFAULT (0) NULL,
    [DebitAmtFgn]  [dbo].[pDec]         CONSTRAINT [DF__tblBrRecu__Debit__44F918AC] DEFAULT (0) NULL,
    [CreditAmt]    [dbo].[pDec]         CONSTRAINT [DF__tblBrRecu__Credi__45ED3CE5] DEFAULT (0) NULL,
    [CreditAmtFgn] [dbo].[pDec]         CONSTRAINT [DF__tblBrRecu__Credi__46E1611E] DEFAULT (0) NULL,
    [Descr]        [dbo].[pDescription] NULL,
    [Reference]    VARCHAR (15)         NULL,
    [ts]           ROWVERSION           NULL,
    [CF]           XML                  NULL,
    CONSTRAINT [PK__tblBrRecurDetail__63D8CE75] PRIMARY KEY CLUSTERED ([EntryNum] ASC) WITH (FILLFACTOR = 80)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrRecurDetail';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblBrRecurDetail';

