CREATE TABLE [dbo].[tblSmActivity] (
    [ActivityId]  UNIQUEIDENTIFIER  NOT NULL,
    [FunctionId]  UNIQUEIDENTIFIER  NOT NULL,
    [PostRun]     [dbo].[pPostRun]  NULL,
    [RunTime]     DATETIME          NULL,
    [Description] VARCHAR (50)      NULL,
    [Comments]    VARCHAR (50)      NULL,
    [UserId]      [dbo].[pUserID]   NULL,
    [WrkStnId]    [dbo].[pWrkStnID] NULL,
    [ts]          ROWVERSION        NULL,
    CONSTRAINT [PK_tblSmActivity] PRIMARY KEY NONCLUSTERED ([ActivityId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmActivity';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmActivity';

