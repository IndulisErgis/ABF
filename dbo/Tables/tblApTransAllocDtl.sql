CREATE TABLE [dbo].[tblApTransAllocDtl] (
    [TransId]   [dbo].[pTransID] NOT NULL,
    [EntryNum]  INT              NOT NULL,
    [Counter]   INT              IDENTITY (1, 1) NOT NULL,
    [AcctId]    [dbo].[pGlAcct]  NULL,
    [Amount]    [dbo].[pDec]     DEFAULT ((0)) NULL,
    [AmountFgn] [dbo].[pDec]     DEFAULT ((0)) NULL,
    [ts]        ROWVERSION       NULL,
    [CF]        XML              NULL,
    CONSTRAINT [PK__tblApTransAllocDtl] PRIMARY KEY CLUSTERED ([TransId] ASC, [EntryNum] ASC, [Counter] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransAllocDtl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransAllocDtl';

