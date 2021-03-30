CREATE TABLE [dbo].[tblSmBatch] (
    [FunctionId] VARCHAR (10)     NOT NULL,
    [BatchId]    [dbo].[pBatchID] NOT NULL,
    [Descr]      VARCHAR (50)     NULL,
    [CreateDate] DATETIME         NULL,
    [Lock]       BIT              CONSTRAINT [DF_tblSmBatch_Lock] DEFAULT ((0)) NOT NULL,
    [LockBy]     [dbo].[pUserID]  NULL,
    [LockDate]   DATETIME         NULL,
    [ProcessId]  UNIQUEIDENTIFIER NULL,
    [Status]     XML              NULL,
    [Permanent]  BIT              CONSTRAINT [DF_tblSmBatch_Permanent] DEFAULT ((0)) NOT NULL,
    [CF]         XML              NULL,
    [ts]         ROWVERSION       NULL,
    [DefaultYn]  BIT              CONSTRAINT [DF_tblSmBatch_DefaultYn] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tblSmBatch] PRIMARY KEY CLUSTERED ([FunctionId] ASC, [BatchId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmBatch';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSmBatch';

