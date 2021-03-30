CREATE TABLE [dbo].[tblSysAudit] (
    [SeqNo]      INT              IDENTITY (1, 1) NOT NULL,
    [AuditType]  TINYINT          NOT NULL,
    [FunctionId] NVARCHAR (50)    NOT NULL,
    [ObjectId]   NVARCHAR (255)   NOT NULL,
    [KeyValue]   NVARCHAR (255)   NULL,
    [SessionId]  [dbo].[pPostRun] NOT NULL,
    [UserId]     [dbo].[pUserID]  NOT NULL,
    [EventTime]  DATETIME         CONSTRAINT [DF_tblSysAudit_EventTime] DEFAULT (getdate()) NOT NULL,
    [EventData]  NTEXT            NULL,
    CONSTRAINT [PK_tblSysAudit] PRIMARY KEY CLUSTERED ([SeqNo] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysAudit';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblSysAudit';

