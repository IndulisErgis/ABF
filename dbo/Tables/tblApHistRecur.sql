CREATE TABLE [dbo].[tblApHistRecur] (
    [Counter]   INT              IDENTITY (1, 1) NOT NULL,
    [RecurID]   VARCHAR (10)     NOT NULL,
    [CopyDate]  DATETIME         NOT NULL,
    [BillDate]  DATETIME         NULL,
    [Amount]    [dbo].[pDec]     DEFAULT ((0)) NULL,
    [AmountFgn] [dbo].[pDec]     DEFAULT ((0)) NULL,
    [PostRun]   [dbo].[pPostRun] NULL,
    [TransID]   [dbo].[pTransID] NOT NULL,
    [Source]    TINYINT          DEFAULT ((0)) NOT NULL,
    [UserID]    [dbo].[pUserID]  NOT NULL,
    [CF]        XML              NULL,
    CONSTRAINT [PK_tblApHistRecur] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblApHistRecur_PostRunTransIDBillDate]
    ON [dbo].[tblApHistRecur]([PostRun] ASC, [TransID] ASC, [BillDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistRecur';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblApHistRecur';

