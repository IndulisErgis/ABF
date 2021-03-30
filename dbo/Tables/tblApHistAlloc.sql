CREATE TABLE [dbo].[tblApHistAlloc] (
    [PostRun]      [dbo].[pPostRun]    NOT NULL,
    [TransId]      [dbo].[pTransID]    NOT NULL,
    [InvoiceNum]   [dbo].[pInvoiceNum] NOT NULL,
    [EntryNum]     INT                 NOT NULL,
    [Counter]      INT                 IDENTITY (1, 1) NOT NULL,
    [TransAllocId] VARCHAR (10)        NOT NULL,
    [AcctId]       [dbo].[pGlAcct]     NULL,
    [Amount]       [dbo].[pDec]        DEFAULT ((0)) NULL,
    [AmountFgn]    [dbo].[pDec]        DEFAULT ((0)) NULL,
    [ts]           ROWVERSION          NULL,
    [CF]           XML                 NULL,
    CONSTRAINT [PK__tblApHistAlloc] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC, [InvoiceNum] ASC, [EntryNum] ASC, [Counter] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistAlloc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistAlloc';

