CREATE TABLE [dbo].[tblApTransAlloc] (
    [TransId]      [dbo].[pTransID] NOT NULL,
    [EntryNum]     INT              NOT NULL,
    [TransAllocId] VARCHAR (10)     NOT NULL,
    [ts]           ROWVERSION       NULL,
    [CF]           XML              NULL,
    [Segments]     [dbo].[pGlAcct]  NULL,
    CONSTRAINT [PK__tblApTransAlloc] PRIMARY KEY CLUSTERED ([TransId] ASC, [EntryNum] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransAlloc';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApTransAlloc';

