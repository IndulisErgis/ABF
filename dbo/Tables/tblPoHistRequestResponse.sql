CREATE TABLE [dbo].[tblPoHistRequestResponse] (
    [SeqNum]       INT           IDENTITY (1, 1) NOT NULL,
    [PostRun]      NVARCHAR (14) NULL,
    [TransId]      NVARCHAR (8)  NULL,
    [Response]     SMALLINT      NULL,
    [ResponseUser] INT           NULL,
    [ResponseDate] DATETIME      NULL,
    [Comments]     TEXT          NULL,
    [CF]           XML           NULL,
    CONSTRAINT [PK__tblPoHistRequestResponse] PRIMARY KEY CLUSTERED ([SeqNum] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblPoHistRequestResponse]
    ON [dbo].[tblPoHistRequestResponse]([PostRun] ASC, [TransId] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistRequestResponse';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblPoHistRequestResponse';

