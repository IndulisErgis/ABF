CREATE TABLE [dbo].[tblSmTransControl] (
    [FunctionId] VARCHAR (10)     NOT NULL,
    [BatchId]    [dbo].[pBatchID] NOT NULL,
    [TransId]    VARCHAR (255)    NOT NULL,
    [UserId]     [dbo].[pUserID]  NOT NULL,
    [LockDate]   DATETIME         CONSTRAINT [DF_tblSmTransControl_LockDate] DEFAULT (getdate()) NOT NULL,
    [ProcessId]  UNIQUEIDENTIFIER NULL,
    [ts]         ROWVERSION       NULL,
    CONSTRAINT [PK_tblSmTransCtrl] PRIMARY KEY CLUSTERED ([FunctionId] ASC, [TransId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTransControl';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmTransControl';

