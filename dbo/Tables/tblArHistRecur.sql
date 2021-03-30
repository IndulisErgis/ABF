CREATE TABLE [dbo].[tblArHistRecur] (
    [Counter]  INT              IDENTITY (1, 1) NOT NULL,
    [Source]   TINYINT          CONSTRAINT [DF_tblArHistRecur_Source] DEFAULT ((0)) NOT NULL,
    [RecurId]  VARCHAR (8)      NOT NULL,
    [CopyDate] DATETIME         NOT NULL,
    [BillDate] DATETIME         NULL,
    [Amount]   [dbo].[pDec]     CONSTRAINT [DF_tblArHistRecur_Amount] DEFAULT ((0)) NOT NULL,
    [PostRun]  [dbo].[pPostRun] NULL,
    [TransId]  [dbo].[pTransID] NOT NULL,
    [UserId]   [dbo].[pUserID]  NOT NULL,
    [CF]       XML              NULL,
    CONSTRAINT [PK_tblArHistRecur] PRIMARY KEY CLUSTERED ([Counter] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblArHistRecur_PostRunSourceTransIDBillDate]
    ON [dbo].[tblArHistRecur]([PostRun] ASC, [Source] ASC, [TransId] ASC, [BillDate] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistRecur';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblArHistRecur';

