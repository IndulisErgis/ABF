CREATE TABLE [dbo].[tblMpHistoryRequirements] (
    [PostRun]           [dbo].[pPostRun]     NOT NULL,
    [TransId]           INT                  NOT NULL,
    [OrderNo]           [dbo].[pTransID]     NULL,
    [ReleaseNo]         VARCHAR (3)          NULL,
    [ReqId]             INT                  NOT NULL,
    [ParentId]          INT                  NULL,
    [IndLevel]          INT                  NOT NULL,
    [Step]              INT                  NULL,
    [Description]       [dbo].[pDescription] NULL,
    [Type]              TINYINT              DEFAULT ((0)) NOT NULL,
    [BLT]               INT                  DEFAULT ((0)) NOT NULL,
    [QTY]               [dbo].[pDec]         DEFAULT ((1)) NOT NULL,
    [ReqSeq]            INT                  DEFAULT ((0)) NOT NULL,
    [ts]                ROWVERSION           NULL,
    [CF]                XML                  NULL,
    [ReleaseId]         INT                  NOT NULL,
    [_ParentId]         INT                  NULL,
    [EstProcessTime]    BIGINT               CONSTRAINT [DF_tblMpHistoryRequirements_EstProcessTime] DEFAULT ((0)) NOT NULL,
    [EstStartDate]      DATETIME             NULL,
    [EstCompletionDate] DATETIME             NULL,
    CONSTRAINT [PK_tblMpHistoryRequirements] PRIMARY KEY CLUSTERED ([PostRun] ASC, [TransId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'Version', @value = '11.0.19137.3213', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryRequirements';


GO
EXECUTE sp_addextendedproperty @name = N'Comment', @value = 'Build 19137', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblMpHistoryRequirements';

